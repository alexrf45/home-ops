output "client_configuration" {
  value     = module.testing.client_configuration
  sensitive = true
}

output "kubeconfig" {
  value     = module.testing.kubeconfig
  sensitive = true
}

output "kubeclientconfig" {
  value     = module.testing.kubeclientconfig
  sensitive = true
}
