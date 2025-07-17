output "client_configuration" {
  value     = module.testing.client_configuration
  sensitive = true
}

output "kube_config" {
  value     = module.testing.kube_config
  sensitive = true
}
output "machine_config" {
  value     = module.testing.machine_config
  sensitive = true
}
