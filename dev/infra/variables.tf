variable "password" {
  description = "pve node password"
  type        = string
  sensitive   = true
}

variable "github_pat" {
  description = "github PAT used to auth to git"
  type        = string
  sensitive   = true
}

variable "github_owner" {
  description = "github repo owner"
  type        = string
}

variable "github_repository" {
  description = "Information about new GitHub repository for FluxCD"
  type = object({
    name        = string
    description = string
    visibility  = string
  })
  default = {
    name        = "fr3d"
    description = "Homelab built with Talos on Proxmox and managed with Flux"
    visibility  = "private"
  }
}

variable "cluster" {
  description = "Cluster configuration"
  type = object({
    name          = string
    endpoint      = string
    gateway       = string
    talos_version = string
    platform      = string
    iso_datastore = string
  })
}
