module "secrets" {
  depends_on = [module.dev]
  source     = "./cluster-secrets"
  token      = var.token
  username   = "fr3d"
}
