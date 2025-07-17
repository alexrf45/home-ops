terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  backend "s3" {

  }
}


provider "aws" {
  region = "us-west-2"
}



module "home-lab-testing" {
  source     = "github.com/alexrf45/lab//s3-remote-state?ref=v1.4.4"
  env        = "testing"
  app        = "home-0ps"
  versioning = "Disabled"
}


output "s3_bucket_arn" {
  value       = module.home-lab-testing.s3_bucket_arn
  description = "The ARN of the S3 bucket"
}

output "bucket_name" {
  value       = module.home-lab-testing.bucket_name
  description = "The name of the bucket"
}

output "dynamodb_table_name" {
  value = module.home-lab-testing.dynamodb_table_name
}

output "dynamodb_arn" {
  value       = module.home-lab-testing.dynamodb_arn
  description = "ARN of dynamodb_table"
}
