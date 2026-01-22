resource "talos_machine_secrets" "this" {
  talos_version = var.talos.version
}

data "talos_client_configuration" "this" {
  cluster_name         = var.talos.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes = [
    for k, v in merge(var.worker_nodes, var.controlplane_nodes) : v.ip
  ]
  endpoints = [for k, v in var.controlplane_nodes : v.ip]
}

data "talos_machine_configuration" "controlplane" {
  depends_on = [
    proxmox_virtual_environment_vm.controlplane,
  ]
  for_each         = var.controlplane_nodes
  cluster_name     = var.talos.name
  cluster_endpoint = "https://${var.talos.endpoint}:6443"
  talos_version    = var.talos.version
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [
    templatefile("${path.module}/templates/control_plane.yaml.tftpl", {
      install_disk  = var.talos.install_disk
      install_image = talos_image_factory_schematic.controlplane.id
      storage_disk  = var.talos.storage_disk
      #hostname         = format("${var.env}-${var.talos.name}-cp-${random_id.this[each.key].hex}")
      allow_scheduling = each.value.allow_scheduling
      #node_name        = each.value.node
      talos_name  = var.talos.name
      endpoint    = var.pve.endpoint
      vip_ip      = var.talos.vip_ip
      nameserver1 = var.nameservers.primary
      nameserver2 = var.nameservers.secondary
    }),
    yamlencode({
      talos = {
        inlineManifests = [

          {
            name = "cilium"
            contents = join("---\n", [
              data.helm_template.this.manifest,
              "# Source cilium.tf\n${local.cilium_lb_manifest}",
            ])
          }
        ]
      }
    }),
  ]
}

data "talos_machine_configuration" "worker" {
  depends_on = [
    proxmox_virtual_environment_vm.worker
  ]
  for_each         = var.worker_nodes
  cluster_name     = var.talos.name
  cluster_endpoint = "https://${var.talos.endpoint}:6443"
  talos_version    = var.talos.version
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = [
    templatefile("${path.module}/templates/node.yaml.tftpl", {
      install_disk  = var.talos.install_disk
      storage_disk  = var.talos.storage_disk
      install_image = talos_image_factory_schematic.worker.id
      #hostname      = format("${var.env}-${var.talos.name}-node-${random_id.this[each.key].hex}")
      #node_name     = each.value.node
      talos_name  = var.talos.name
      nameserver1 = var.nameservers.primary
      nameserver2 = var.nameservers.secondary
    }),
  ]
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [
    proxmox_virtual_environment_vm.controlplane,
    data.talos_machine_configuration.controlplane,
  ]
  apply_mode = "auto"
  for_each   = var.controlplane_nodes
  node       = each.value.ip

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane[each.key].machine_configuration

  timeouts = {
    create = "5m"
  }
  lifecycle {
    # re-run config apply if vm changes
    replace_triggered_by = [proxmox_virtual_environment_vm.controlplane[each.key]]
  }

}
resource "talos_machine_configuration_apply" "worker" {
  depends_on = [
    proxmox_virtual_environment_vm.worker,
    data.talos_machine_configuration.worker
  ]
  apply_mode = "auto"
  for_each   = var.worker_nodes
  node       = each.value.ip

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration

  timeouts = {
    create = "5m"
  }
  lifecycle {
    # re-run config apply if vm changes
    replace_triggered_by = [proxmox_virtual_environment_vm.worker[each.key]]
  }

}

resource "time_sleep" "wait_until_apply" {
  depends_on = [
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker
  ]
  create_duration = "30s"
}


resource "talos_machine_bootstrap" "this" {
  count = var.bootstrap_cluster ? 1 : 0
  depends_on = [
    time_sleep.wait_until_apply,
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker
  ]
  node                 = var.talos.endpoint
  endpoint             = var.talos.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration
  timeouts = {
    create = "3m"
  }
}

resource "time_sleep" "wait_until_bootstrap" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  create_duration = "30s"
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    time_sleep.wait_until_bootstrap
  ]
  node                 = var.talos.endpoint
  endpoint             = var.talos.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration
  timeouts = {
    read   = "1m"
    create = "5m"
  }
}

