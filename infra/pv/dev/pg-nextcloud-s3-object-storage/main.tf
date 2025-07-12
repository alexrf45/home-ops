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
  username   = "dev-nextcloud-object-store-user"
  path       = "/dev/nextcloud/storage/"
  versioning = "Enabled"
}
