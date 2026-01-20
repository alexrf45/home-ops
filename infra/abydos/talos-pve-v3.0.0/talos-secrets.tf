# talos-secrets.tf - Talos machine secrets and encryption

#------------------------------------------------------------------------------
# Machine Secrets
#------------------------------------------------------------------------------
resource "talos_machine_secrets" "this" {
  talos_version = var.cluster.talos_version
}

#------------------------------------------------------------------------------
# Client Configuration
#------------------------------------------------------------------------------
data "talos_client_configuration" "this" {
  depends_on = [
    proxmox_virtual_environment_vm.controlplane,
    proxmox_virtual_environment_vm.worker
  ]

  cluster_name         = var.cluster.name
  client_configuration = talos_machine_secrets.this.client_configuration
  nodes                = local.all_node_ips
  endpoints            = local.controlplane_ips
}

