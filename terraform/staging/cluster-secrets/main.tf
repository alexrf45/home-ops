

module "secrets" {
  source            = "./module"
  token             = var.token
  username          = "fr3d"
  access-key-id     = var.access-key-id
  secret-access-key = var.secret-access-key
}
