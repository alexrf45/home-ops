output "secret" {
  value     = module.app.secret
  sensitive = true
}

output "cname" {
  value = module.app.cname

}

output "tunnel_token" {
  value     = module.app.tunnel_token
  sensitive = true
}

output "service_record" {
  value = module.app.service_record
}
