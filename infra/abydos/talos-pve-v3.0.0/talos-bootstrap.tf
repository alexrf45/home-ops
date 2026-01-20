# talos-bootstrap.tf - Cluster bootstrap with conditional creation

#------------------------------------------------------------------------------
# Wait for Control Plane Configuration
#------------------------------------------------------------------------------
resource "time_sleep" "wait_for_controlplane_config" {
  depends_on = [
    talos_machine_configuration_apply.controlplane,
    proxmox_virtual_environment_vm.controlplane
  ]

  create_duration = "15s"
}

#------------------------------------------------------------------------------
# Bootstrap Cluster
# IMPORTANT: Set bootstrap_cluster = false after initial deployment
#------------------------------------------------------------------------------
resource "talos_machine_bootstrap" "this" {
  # Only create on initial deployment
  count = var.bootstrap_cluster ? 1 : 0

  depends_on = [
    time_sleep.wait_for_controlplane_config
  ]

  node                 = local.first_controlplane_ip
  endpoint             = var.cluster.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration

  timeouts = {
    create = "5m"
  }
}

#------------------------------------------------------------------------------
# Wait for Bootstrap to Complete
#------------------------------------------------------------------------------
resource "time_sleep" "wait_for_bootstrap" {
  count = var.bootstrap_cluster ? 1 : 0

  depends_on = [
    talos_machine_bootstrap.this
  ]

  create_duration = "30s"
}

#------------------------------------------------------------------------------
# Kubeconfig
#------------------------------------------------------------------------------
resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    time_sleep.wait_for_bootstrap,
    talos_machine_bootstrap.this
  ]

  node                 = local.first_controlplane_ip
  endpoint             = var.cluster.endpoint
  client_configuration = talos_machine_secrets.this.client_configuration

  timeouts = {
    read   = "1m"
    create = "5m"
  }
}

#------------------------------------------------------------------------------
# Health Check (Optional - More Robust Than time_sleep)
#------------------------------------------------------------------------------
resource "null_resource" "cluster_health_check" {
  count = var.bootstrap_cluster ? 1 : 0

  depends_on = [
    talos_cluster_kubeconfig.this
  ]

  triggers = {
    cluster_endpoint = var.cluster.endpoint
  }

  provisioner "local-exec" {
    command = <<-EOT
      echo "Waiting for cluster to be healthy..."
      for i in $(seq 1 ${var.wait_for_bootstrap_timeout / 10}); do
        if kubectl --kubeconfig <(echo '${talos_cluster_kubeconfig.this.kubeconfig_raw}') get nodes >/dev/null 2>&1; then
          echo "Cluster is healthy!"
          exit 0
        fi
        echo "Attempt $i: Cluster not ready yet, waiting..."
        sleep 10
      done
      echo "ERROR: Cluster health check timed out"
      exit 1
    EOT

    interpreter = ["/bin/bash", "-c"]
  }
}
