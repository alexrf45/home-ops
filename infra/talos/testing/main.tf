#NOTE: Consider building another helm chart into cluster bootstrap
#NOTE: deploy main module first then build out k8s/flux bootstrap
#TEST: not yet. Will deploy either later tonight or in the morning


module "testing" {
  source = "./module"
  # source    = "git@github.com:alexrf45/lab.git//talos-pve-v1.3.3?ref=v1.4.1"
  cluster       = var.cluster
  pve_config    = var.pve_config
  node_config   = var.node_config
  cilium_config = var.cilium_config
  dns_servers   = var.dns_servers
}

# module "bootstrap" {
#   depends_on = [module.test]
#   source     = "./bootstrap"
# }
