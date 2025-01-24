output "password" {
  value     = module.secrets.password
  sensitive = true
}

output "password-grafana" {
  value     = module.secrets.password-grafana
  sensitive = true
}
