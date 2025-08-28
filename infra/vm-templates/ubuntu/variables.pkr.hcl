variable "proxmox_url" {
  type = string
}

variable "username" {
  type = string
}

variable "password" {
  type      = string
  sensitive = true
}

locals {
  disk_storage = "local-lvm"
}
