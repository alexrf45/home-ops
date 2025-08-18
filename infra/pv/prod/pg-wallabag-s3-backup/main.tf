terraform {
  backend "s3" {}
}


data "aws_caller_identity" "current" {}

provider "aws" {}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "wallabag" {
  source     = "./module/"
  env        = "prod"
  app        = "wallabag"
  username   = "prod-wallabag-pg-db-user"
  path       = "/backup/prod/wallabag/"
  versioning = "Enabled"
}
