provider "aws" {

}

provider "talos" {
}

provider "proxmox" {
  endpoint = "https://${var.pve.endpoint}:8006"
  username = "root@pam"
  password = var.pve.password
  insecure = true
  ssh {
    agent = false
  }
}


