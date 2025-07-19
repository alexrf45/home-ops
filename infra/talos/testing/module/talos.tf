resource "talos_machine_secrets" "this" {
  talos_version = var.talos_config.talos_version
}

data "talos_client_configuration" "this" {
  depends_on = [
    proxmox_virtual_environment_vm.this
  ]
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = [for k, v in var.nodes : v.ip]
  endpoints            = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"]
}

data "talos_machine_configuration" "this" {
  for_each         = var.nodes
  cluster_name     = var.cluster_name
  cluster_endpoint = "https://${var.talos_config.endpoint}:6443"
  talos_version    = var.talos_config.talos_version
  machine_type     = each.value.machine_type
  machine_secrets  = talos_machine_secrets.this.machine_secrets
  config_patches = each.value.machine_type == "controlplane" ? [
    templatefile("${path.module}/templates/control_plane.yaml.tftpl", {
      hostname         = format("%s-controlplane-%s-%s", var.environment, random_id.this.id, each.key)
      allow_scheduling = var.talos_config.allow_scheduling
      cluster_name     = var.cluster_name
      endpoint         = var.talos_config.endpoint
      vip_ip           = var.talos_config.vip_ip
      install_disk     = var.talos_config.install_disk
      install_image    = talos_image_factory_schematic.controlplane.id
      nameserver1      = var.dns_servers.primary
      nameserver2      = var.dns_servers.secondary
    }),
    templatefile("${path.module}/templates/patch.yaml.tftpl", {
      tailscale_auth = var.talos_config.tailscale_auth
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
      install_disk  = var.talos_config.install_disk
      environment   = var.environment
      install_image = talos_image_factory_schematic.worker.id
      hostname      = format("%s-node-%s-%s", var.environment, random_id.that.id, each.key)
      cluster_name  = var.cluster_name
      nameserver1   = var.dns_servers.primary
      nameserver2   = var.dns_servers.secondary
    }),
  ]
}


resource "talos_machine_configuration_apply" "this" {
  depends_on = [
    proxmox_virtual_environment_vm.this,
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
    replace_triggered_by = [proxmox_virtual_environment_vm.this[each.key]]
  }

}



#You only need to bootstrap 1 control node, we pick the first one
resource "talos_machine_bootstrap" "this" {
  depends_on = [
    proxmox_virtual_environment_vm.this,
    talos_machine_configuration_apply.this
  ]
  node                 = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"][0]
  endpoint             = var.talos_config.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration
  timeouts = {
    create = "5m"
  }
}

resource "time_sleep" "wait_until_bootstrap" {
  depends_on = [
    talos_machine_bootstrap.this,
    proxmox_virtual_environment_vm.this
  ]
  create_duration = "2m"
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    time_sleep.wait_until_bootstrap
  ]
  node                 = [for k, v in var.nodes : v.ip if v.machine_type == "controlplane"][0]
  endpoint             = var.talos_config.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration
  timeouts = {
    read   = "1m"
    create = "5m"
  }
}

