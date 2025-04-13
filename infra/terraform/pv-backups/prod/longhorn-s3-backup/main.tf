terraform {
  backend "s3" {}
}


data "aws_caller_identity" "current" {}

provider "aws" {}

provider "kubernetes" {
  config_path = "~/.kube/prod"
}

module "longhorn" {
  source     = "./module/"
  env        = "prod"
  app        = "storage"
  username   = "prod-lg-user"
  path       = "/backup/prod/"
  versioning = "Enabled"
}
