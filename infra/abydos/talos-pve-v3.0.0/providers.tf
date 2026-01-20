# Helm provider - configured after cluster is available
provider "helm" {
  kubernetes = {
    host                   = try(talos_cluster_kubeconfig.this.kubernetes_client_configuration.host, "")
    client_certificate     = try(base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate), "")
    client_key             = try(base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key), "")
    cluster_ca_certificate = try(base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate), "")
  }
}

# Kubectl provider - for applying manifests
provider "kubectl" {
  host                   = try(talos_cluster_kubeconfig.this.kubernetes_client_configuration.host, "")
  client_certificate     = try(base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate), "")
  client_key             = try(base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key), "")
  cluster_ca_certificate = try(base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate), "")
  load_config_file       = false
}
