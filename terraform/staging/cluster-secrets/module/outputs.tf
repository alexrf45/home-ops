output "password" {
  value     = random_string.pihole-password.result
  sensitive = true
}
output "password-grafana" {
  value     = random_string.grafana-password.result
  sensitive = true
}
