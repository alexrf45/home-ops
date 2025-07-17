output "client_configuration" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kube_config" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "machine_config" {
  value     = data.talos_machine_configuration.this["v1"].machine_configuration
  sensitive = true
}
