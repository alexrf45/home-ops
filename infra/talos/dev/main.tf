module "dev" {
  # source = "./module-testing"
  source        = "git@github.com:alexrf45/lab.git//talos-pve-v1.5.1?ref=dev"
  environment   = var.environment
  cluster       = var.cluster
  pve_config    = var.pve_config
  nodes         = var.nodes
  cilium_config = var.cilium_config
  dns_servers   = var.dns_servers
}
