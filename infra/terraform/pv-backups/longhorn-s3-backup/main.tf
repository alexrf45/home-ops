terraform {
  backend "s3" {}
}


data "aws_caller_identity" "current" {}

provider "aws" {}

provider "kubernetes" {
  config_path = "~/.kube/dev"
}

module "longhorn" {
  source     = "./module/"
  env        = "dev"
  app        = "storage"
  username   = "dev-lg-user"
  path       = "/backup/dev/"
  versioning = "Enabled"
}
