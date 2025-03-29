terraform {
  backend "s3" {}
}


data "aws_caller_identity" "current" {}

provider "aws" {}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "longhorn" {
  source     = "./module/"
  env        = "prod"
  app        = "longhorn-system"
  username   = "lg-user"
  path       = "/backup/"
  versioning = "Enabled"
}
