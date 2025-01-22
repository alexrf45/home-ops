output "password" {
  value     = random_string.pihole-password.result
  sensitive = true
}

output "aws_secret" {
  value     = aws_iam_access_key.external-secrets.secret
  sensitive = true
}
