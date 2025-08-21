terraform {
  backend "s3" {}
}


data "aws_caller_identity" "current" {}

provider "aws" {}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

module "firefly" {
  source     = "./module/"
  env        = "dev"
  app        = "firefly"
  username   = "dev-firefly-pg-db-user"
  path       = "/backup/dev/firefly/"
  versioning = "Disabled"
}
