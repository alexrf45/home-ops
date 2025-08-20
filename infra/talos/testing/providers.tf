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
