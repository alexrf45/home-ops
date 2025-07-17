provider "talos" {
}

provider "proxmox" {
  endpoint = "https://10.3.3.9:8006"
  username = "root@pam"
  password = var.password
  insecure = true
  ssh {
    agent = false
  }
}
