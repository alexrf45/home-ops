output "password" {
  value     = module.secrets.password
  sensitive = true
}

output "aws_secret" {
  value     = module.secrets.aws_secret
  sensitive = true
}
