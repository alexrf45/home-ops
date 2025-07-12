output "caller_arn" {
  value = data.aws_caller_identity.current.arn
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "s3_bucket_arn" {
  value       = module.wallabag.s3_bucket_arn
  description = "The ARN of the S3 bucket"
}

output "bucket_name" {
  value       = module.wallabag.bucket_name
  description = "The name of the bucket"
}

output "bucket_url" {
  value = module.wallabag.bucket_url
}


output "user_arn" {
  value       = module.wallabag.user_arn
  description = "iam user arn"
}

output "iam_role_arn" {
  value       = module.wallabag.iam_role_arn
  description = "iam role arn"
}

output "access_id" {
  value     = module.wallabag.access_id
  sensitive = true
}

output "secret" {
  value     = module.wallabag.secret
  sensitive = true
}
