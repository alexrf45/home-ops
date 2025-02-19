provider "aws" {

}

provider "talos" {
}

provider "proxmox" {
  endpoint = "https://${var.pve_endpoint}:8006"
  username = "root@pam"
  password = var.password
  insecure = true
  ssh {
    agent = false
  }
}


