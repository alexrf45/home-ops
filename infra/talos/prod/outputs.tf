output "client_configuration" {
  value     = module.prod.client_configuration
  sensitive = true
}

output "kubeconfig" {
  value     = module.prod.kubeconfig
  sensitive = true
}
