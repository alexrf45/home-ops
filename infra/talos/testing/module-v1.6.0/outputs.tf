output "client_configuration" {
  value     = data.talos_client_configuration.this.talos_config
  sensitive = true
}

output "kubeconfig" {
  value     = talos_cluster_kubeconfig.this.kubeconfig_raw
  sensitive = true
}

output "kubeclientconfig" {
  value = talos_cluster_kubeconfig.this.kubernetes_client_configuration
}
