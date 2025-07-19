# outputs.tf
output "client_configuration" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kube_config" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "machine_config" {
  value     = data.talos_machine_configuration.this.machine_configuration
  sensitive = true
}

output "control_plane_ips" {
  value       = local.control_plane_ips
  description = "IP addresses of control plane nodes"
}

output "worker_ips" {
  value       = local.worker_ips
  description = "IP addresses of worker nodes"
}

output "cluster_endpoint" {
  value       = var.cluster.endpoint
  description = "Kubernetes API endpoint"
}
