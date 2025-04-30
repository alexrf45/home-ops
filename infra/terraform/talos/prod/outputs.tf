

output "client_configuration" {
  value     = module.prod.client_configuration
  sensitive = true
}

output "kube_config" {
  value     = module.prod.kube_config
  sensitive = true
}
output "machine_config" {
  value     = module.prod.machine_config
  sensitive = true
}
