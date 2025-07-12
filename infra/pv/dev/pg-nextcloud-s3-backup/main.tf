terraform {
  backend "s3" {}
}

data "aws_caller_identity" "current" {}

provider "aws" {}

provider "kubernetes" {
  config_path = "~/.kube/dev"
}

module "nextcloud" {
  source     = "./module/"
  env        = "dev"
  app        = "nextcloud"
  username   = "dev-nextcloud-pg-db-user"
  path       = "/backup/dev/nextcloud/"
  versioning = "Enabled"
}
