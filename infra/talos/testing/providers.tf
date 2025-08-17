provider "aws" {

}

provider "talos" {
}

provider "proxmox" {
  endpoint = "https://${var.pve_config.pve_endpoint}:8006"
  username = "root@pam"
  password = var.pve_config.password
  insecure = true
  ssh {
    agent = false
  }
}


provider "kubernetes" {
  host                   = var.cluster.endpoint
  client_certificate     = base64decode(module.testing.kubeclientconfig.kubernetes_client_configuration.client_certificate)
  client_key             = base64decode(module.testing.kubeclientconfig.kubernetes_client_configuration.client_key)
  cluster_ca_certificate = base64decode(module.testing.kubeclientconfig.kubernetes_client_configuration.ca_certificate)
}

provider "flux" {
  kubernetes = {
    host                   = var.cluster.endpoint
    client_certificate     = base64decode(module.testing.kubeclientconfig.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(module.testing.kubeclientconfig.kubernetes_client_configuration.client_key)
    cluster_ca_certificate = base64decode(module.testing.kubeclientconfig.kubernetes_client_configuration.ca_certificate)

    git = {
      url = "ssh://git@github.com/${var.github_org}/${var.github_repository}.git"
      ssh = {
        username    = "git"
        private_key = var.ssh_key_path
      }
    }

  }
}
