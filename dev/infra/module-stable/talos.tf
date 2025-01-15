resource "talos_machine_secrets" "talos_secrets" {
  talos_version = var.cluster.talos_version
}
data "talos_client_configuration" "this" {
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.talos_secrets.client_configuration
  nodes                = [for k, v in var.nodes : v.ip]
  endpoints            = [for k, v in var.controlplanes : v.ip]
}

data "talos_machine_configuration" "this" {
  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${var.cluster.endpoint}:6443"
  talos_version    = var.cluster.talos_version
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.talos_secrets.machine_secrets
}
data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${var.cluster.endpoint}:6443"
  talos_version    = var.cluster.talos_version
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.talos_secrets.machine_secrets
}
resource "talos_machine_configuration_apply" "this" {
  depends_on = [
    proxmox_virtual_environment_vm.talos_vm_control_plane,
    data.talos_machine_configuration.this
  ]
  apply_mode           = "reboot"
  for_each             = var.controlplanes
  node                 = var.cluster.endpoint
  endpoint             = var.cluster.endpoint
  client_configuration = data.talos_client_configuration.this.client_configuration
  #client_configuration        = talos_machine_secrets.talos_secrets.client_configuration
  machine_configuration_input = data.talos_machine_configuration.this.machine_configuration
  config_patches              = var.machine_config_patches
  timeouts = {
    create = "3m"
  }
  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.talos_vm_control_plane[each.key]]
  }

}



#apply to worker gives tls error. there doesn't seem to be insecure argument in this resource

# resource "talos_machine_configuration_apply" "worker" {
#   depends_on = [
#     proxmox_virtual_environment_vm.talos_vm_control_plane,
#     proxmox_virtual_environment_vm.talos_vm,
#     talos_machine_configuration_apply.this,
#     talos_machine_bootstrap.this
#   ]
#   for_each   = var.nodes
#   apply_mode = "reboot"
#   node       = each.value.ip
#   endpoint   = var.cluster.endpoint
#   #client_configuration = talos_machine_secrets.talos_secrets.client_configuration
#   client_configuration        = data.talos_client_configuration.this.client_configuration
#   machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
#   config_patches              = var.machine_config_patches
#   timeouts = {
#     create = "3m"
#   }
#   lifecycle {
#     replace_triggered_by = [proxmox_virtual_environment_vm.talos_vm[each.key]]
#   }
# }
#You only need to bootstrap 1 control node, we pick the first one
resource "talos_machine_bootstrap" "this" {
  depends_on = [
    proxmox_virtual_environment_vm.talos_vm_control_plane,
    talos_machine_configuration_apply.this
  ]
  node                 = var.cluster.endpoint
  endpoint             = var.cluster.endpoint
  client_configuration = talos_machine_secrets.talos_secrets.client_configuration
  timeouts = {
    create = "5m"
  }
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this
  ]
  node                 = var.cluster.endpoint
  endpoint             = var.cluster.endpoint
  client_configuration = talos_machine_secrets.talos_secrets.client_configuration
  timeouts = {
    read   = "1m"
    create = "5m"
  }
}
