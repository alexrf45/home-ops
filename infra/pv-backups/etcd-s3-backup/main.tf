terraform {
  backend "s3" {}
}


data "aws_caller_identity" "current" {}

provider "aws" {}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "etcd" {
  source     = "./module/"
  env        = "prod"
  app        = "etcd-backup"
  username   = "etcd-user"
  path       = "/etcd-backup/"
  versioning = "Enabled"
}
