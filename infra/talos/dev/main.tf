module "testing" {
  source = "./module"
  ## source    = "git@github.com:alexrf45/lab.git//talos-pve-v1.3.3?ref=v1.4.1"
  environment   = var.environment
  cluster_name  = var.cluster_name
  talos_config  = var.talos_config
  pve_config    = var.pve_config
  nodes         = var.nodes
  cilium_config = var.cilium_config
  dns_servers   = var.dns_servers
}

# module "bootstrap" {
#   depends_on = [module.test]
#   source     = "./bootstrap"
# }
