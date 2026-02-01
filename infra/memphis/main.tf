module "memphis" {
  #source = "./talos-pve-v2.0.0"
  source            = "git@github.com:alexrf45/lab.git//talos-pve-v2.0.0?ref=v3.0.0"
  environment       = var.environment
  worker_disk_count = var.worker_disk_count
  cluster           = var.cluster
  pve_hosts         = var.pve_hosts
  nodes             = var.nodes
  cilium_config     = var.cilium_config
  dns_servers       = var.dns_servers
}
