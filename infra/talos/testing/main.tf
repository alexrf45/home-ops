module "testing" {
  #source = "./module-v1.6.0"
  source        = "git@github.com:alexrf45/lab.git//talos-pve-v1.6.1-alpha?ref=v1.6.1-alpha"
  environment   = var.environment
  cluster       = var.cluster
  pve_config    = var.pve_config
  nodes         = var.nodes
  cilium_config = var.cilium_config
  dns_servers   = var.dns_servers
}
