module "abydos" {
  source = "./talos-pve-v3.0.0"
  #source        = "git@github.com:alexrf45/lab.git//talos-pve-v2.0.0"
  environment        = var.environment
  bootstrap_cluster  = var.bootstrap_cluster
  deploy_cilium      = var.deploy_cilium
  cluster            = var.cluster
  pve_hosts          = var.pve_hosts
  network            = var.network
  dns_servers        = var.dns_servers
  controlplane_nodes = var.controlplane_nodes
  worker_nodes       = var.worker_nodes
  cilium_config      = var.cilium_config
  encryption         = var.encryption
  talos_config       = var.talos_config
  security_config    = var.security_config
}
