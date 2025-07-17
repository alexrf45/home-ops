resource "talos_machine_secrets" "this" {
  talos_version = var.cluster.talos_version
}

data "talos_client_configuration" "this" {
  depends_on = [
    proxmox_virtual_environment_vm.talos_vm
  ]
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [for k, v in var.nodes : v.ip]
  endpoints            = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"]
}

data "talos_machine_configuration" "this" {
  for_each         = var.nodes
  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${var.cluster.endpoint}:6443"
  talos_version    = var.cluster.talos_version
  machine_type     = each.value.machine_type
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = each.value.machine_type == "controlplane" ? [
    templatefile("${path.module}/templates/control_plane.yaml.tftpl", {
      install_disk     = each.value.install_disk
      install_image    = talos_image_factory_schematic.controlplane.id
      hostname         = format("%s-%s-controlplane-%s", var.cluster.name, each.value.node, each.value.vm_id)
      allow_scheduling = each.value.allow_scheduling
      node_name        = each.value.node
      cluster_name     = var.cluster.name
      endpoint         = var.cluster.pve_endpoint
      vip_ip           = var.cluster.vip_ip
      nameserver1      = var.cluster.nameserver1
      nameserver2      = var.cluster.nameserver2
    }),
    templatefile("${path.module}/templates/patch.yaml.tftpl", {
      tailscale_auth = var.cluster.tailscale_auth
    }),
    yamlencode({
      cluster = {
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
    ] : [
    templatefile("${path.module}/templates/node.yaml.tftpl", {
      install_disk  = each.value.install_disk
      install_image = talos_image_factory_schematic.worker.id
      hostname      = format("%s-%s-node-%s", var.cluster.name, each.value.node, each.value.vm_id)
      node_name     = each.value.node
      cluster_name  = var.cluster.name
      nameserver1   = var.cluster.nameserver1
      nameserver2   = var.cluster.nameserver2
    }),
  ]
}


resource "talos_machine_configuration_apply" "this" {
  depends_on = [
    proxmox_virtual_environment_vm.talos_vm,
    data.talos_machine_configuration.this
  ]
  for_each                    = var.nodes
  apply_mode                  = "auto"
  node                        = each.value.ip
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this[each.key].machine_configuration

  timeouts = {
    create = "5m"
  }
  lifecycle {
    # re-run config apply if vm changes
    replace_triggered_by = [proxmox_virtual_environment_vm.talos_vm[each.key]]
  }

}



#You only need to bootstrap 1 control node, we pick the first one
resource "talos_machine_bootstrap" "this" {
  depends_on = [
    proxmox_virtual_environment_vm.talos_vm,
    talos_machine_configuration_apply.this
  ]
  node                 = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"][0]
  endpoint             = var.cluster.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration
  timeouts = {
    create = "5m"
  }
}

resource "time_sleep" "wait_until_bootstrap" {
  depends_on = [
    talos_machine_bootstrap.this,
    proxmox_virtual_environment_vm.talos_vm
  ]
  create_duration = "2m"
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    time_sleep.wait_until_bootstrap
  ]
  node                 = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"][0]
  endpoint             = var.cluster.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration
  timeouts = {
    read   = "1m"
    create = "5m"
  }
}

