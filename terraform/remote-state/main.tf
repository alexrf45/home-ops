terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  backend "s3" {

  }
}


provider "aws" {
  region = "us-west-2"
}



module "home-lab" {
  source     = "github.com/alexrf45/lab//s3-remote-state?ref=v0.0.3"
  env        = "prod"
  app        = "home-ops"
  versioning = "Enabled"
}


output "s3_bucket_arn" {
  value       = module.home-lab.s3_bucket_arn
  description = "The ARN of the S3 bucket"
}

output "bucket_name" {
  value       = module.home-lab.bucket_name
  description = "The name of the bucket"
}

output "dynamodb_table_name" {
  value = module.home-lab.dynamodb_table_name
}

output "dynamodb_arn" {
  value       = module.home-lab.dynamodb_arn
  description = "ARN of dynamodb_table"
}
