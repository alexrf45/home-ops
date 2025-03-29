data "aws_caller_identity" "current" {}


module "staging" {
  source     = "../module/"
  env        = "dev"
  app        = "securecodebox-backup"
  username   = "data-user"
  path       = "/securecodebox/"
  versioning = "Disabled"
  item_id    = "securecodebox-s3-staging"
  vault_name = "HomeLab"
}
