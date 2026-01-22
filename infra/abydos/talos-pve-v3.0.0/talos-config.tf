# talos-config.tf - Talos machine configuration

#------------------------------------------------------------------------------
# Control Plane Machine Configuration
#------------------------------------------------------------------------------
data "talos_machine_configuration" "controlplane" {
  for_each = var.controlplane_nodes

  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${var.cluster.endpoint}:6443"
  talos_version    = var.cluster.talos_version
  machine_type     = "controlplane"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  # Base config + optional encryption patch
  config_patches = concat(
    [yamlencode(local.controlplane_configs[each.key])],
    var.encryption.enabled && var.encryption.tpm_based ? [local.controlplane_encryption_patch_tpm] : [],
    var.encryption.enabled && !var.encryption.tpm_based ? [local.controlplane_encryption_patch_static] : []
  )
}

resource "talos_machine_configuration_apply" "controlplane" {
  for_each = var.controlplane_nodes

  depends_on = [
    proxmox_virtual_environment_vm.controlplane,
    data.talos_machine_configuration.controlplane
  ]

  apply_mode                  = "auto"
  node                        = each.value.ip
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.controlplane[each.key].machine_configuration

  timeouts = {
    create = "5m"
  }

  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.controlplane[each.key]]
  }
}

#------------------------------------------------------------------------------
# Worker Machine Configuration
#------------------------------------------------------------------------------
data "talos_machine_configuration" "worker" {
  for_each = var.worker_nodes

  cluster_name     = var.cluster.name
  cluster_endpoint = "https://${var.cluster.endpoint}:6443"
  talos_version    = var.cluster.talos_version
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets.this.machine_secrets

  # Base config + optional encryption patch
  config_patches = concat(
    [yamlencode(local.worker_configs[each.key])],
    var.encryption.enabled && var.encryption.tpm_based ? [local.worker_encryption_patch_tpm] : [],
    var.encryption.enabled && !var.encryption.tpm_based ? [local.worker_encryption_patch_static] : []
  )
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = var.worker_nodes

  depends_on = [
    proxmox_virtual_environment_vm.worker,
    data.talos_machine_configuration.worker,
    # Workers should only join after cluster is bootstrapped
    talos_machine_bootstrap.this
  ]

  apply_mode                  = "auto"
  node                        = each.value.ip
  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration

  timeouts = {
    create = "5m"
  }

  lifecycle {
    replace_triggered_by = [proxmox_virtual_environment_vm.worker[each.key]]
  }
}
