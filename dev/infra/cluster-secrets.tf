module "cluster-secrets" {
  depends_on = [module.dev-test]
  source     = "./cluster-secrets/"
  username   = "fr3d"
  env        = "dev"
}
