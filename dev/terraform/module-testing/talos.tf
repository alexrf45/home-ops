resource "talos_machine_secrets" "this" {
  talos_version = var.cluster.talos_version
}


data "talos_machine_configuration" "controlplane" {
  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${var.cluster.endpoint}:6443"
  talos_version    = var.cluster.talos_version
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}
data "talos_machine_configuration" "worker" {
  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${var.cluster.endpoint}:6443"
  talos_version    = var.cluster.talos_version
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets
}

data "talos_client_configuration" "this" {
  depends_on = [
    proxmox_virtual_environment_vm.talos_vm_control_plane,
    proxmox_virtual_environment_vm.talos_vm
  ]
  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  #nodes                = var.talos_nodes
  endpoints = [for k, v in var.node_data.controlplanes : k]
}

resource "talos_machine_configuration_apply" "controlplane" {
  depends_on = [
    proxmox_virtual_environment_vm.talos_vm_control_plane,
    data.talos_client_configuration.this,
    data.helm_template.cilium_template,
    local_file.cilium_config
  ]
  for_each   = var.node_data.controlplanes
  apply_mode = "auto"
  #node       = var.cluster.endpoint
  node = each.key
  #endpoint                    = var.cluster.endpoint
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane.machine_configuration
  config_patches = [
    templatefile("${path.module}/templates/machine_config_patches.tftpl", {
      hostname      = each.value.hostname == null ? format("%s-controlplane-%s", var.cluster.name, index(keys(var.node_data.controlplanes), each.key)) : each.value.hostname
      install_disk  = each.value.install_disk
      install_image = each.value.install_image
    }),
    file("${path.module}/patches/cp-scheduling.yaml"),
    #file("${path.module}/patches/cilium-cni-patch.yaml")

  ]
  timeouts = {
    create = "5m"
  }

}
resource "talos_machine_configuration_apply" "worker" {
  depends_on = [
    data.helm_template.cilium_template,
    local_file.cilium_config,
    proxmox_virtual_environment_vm.talos_vm,
    proxmox_virtual_environment_vm.talos_vm_control_plane,
    talos_machine_configuration_apply.controlplane,
  ]
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker.machine_configuration
  for_each                    = var.node_data.workers
  node                        = each.key
  #endpoint                    = var.cluster.endpoint
  config_patches = [
    templatefile("${path.module}/templates/machine_config_patches.tftpl", {
      hostname      = each.value.hostname == null ? format("%s-worker-%s", var.cluster.name, index(keys(var.node_data.workers), each.key)) : each.value.hostname
      install_disk  = each.value.install_disk
      install_image = each.value.install_image
    }),
    #file("${path.module}/patches/cilium-cni-patch.yaml"),

  ]
  timeouts = {
    create = "5m"
  }
}



#You only need to bootstrap 1 control node, we pick the first one
resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.controlplane,
    talos_machine_configuration_apply.worker
  ]
  node = var.cluster.endpoint
  #endpoint             = var.cluster.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration
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
  client_configuration = talos_machine_secrets.this.client_configuration
  timeouts = {
    read   = "1m"
    create = "5m"
  }
}



resource "time_sleep" "wait_until_bootstrap" {
  depends_on = [
    local_sensitive_file.kubeconfig,
    local_sensitive_file.talosconfig
  ]
  create_duration = "3m"
}

resource "local_sensitive_file" "kubeconfig" {
  content         = talos_cluster_kubeconfig.this.kubeconfig_raw
  filename        = "${path.root}/configs/kubeconfig"
  file_permission = "0600"
}

resource "local_sensitive_file" "talosconfig" {
  content  = data.talos_client_configuration.this.talos_config
  filename = "${path.root}/configs/talosconfig"
}

resource "local_sensitive_file" "controlplane_config" {
  content  = data.talos_machine_configuration.controlplane.machine_configuration
  filename = "${path.root}/configs/controlplane.yaml"
}

resource "local_sensitive_file" "worker_config" {
  content  = data.talos_machine_configuration.worker.machine_configuration
  filename = "${path.root}/configs/worker.yaml"
}
