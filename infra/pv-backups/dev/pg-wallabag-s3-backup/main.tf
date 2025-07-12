terraform {
  backend "s3" {}
}


data "aws_caller_identity" "current" {}

provider "aws" {}

provider "kubernetes" {
  config_path = "~/.kube/dev"
}

module "wallabag" {
  source     = "./module/"
  env        = "dev"
  app        = "wallabag"
  username   = "dev-wallabag-pg-db-user"
  path       = "/backup/dev/wallabag/"
  versioning = "Enabled"
}
