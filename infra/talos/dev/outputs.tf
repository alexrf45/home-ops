output "client_configuration" {
  value     = module.dev.client_configuration
  sensitive = true
}

output "kubeconfig" {
  value     = module.dev.kubeconfig
  sensitive = true
}
