module "abydos" {
  source = "./talos-pve-v3.0.0"
  #source        = "git@github.com:alexrf45/lab.git//talos-pve-v2.0.0"
  env                = var.env
  bootstrap_cluster  = var.bootstrap_cluster
  talos              = var.talos
  pve                = var.pve
  nameservers        = var.nameservers
  controlplane_nodes = var.controlplane_nodes
  worker_nodes       = var.worker_nodes
  cilium_config      = var.cilium_config
}
