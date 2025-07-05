terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.78.2"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.8.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
  }
  backend "s3" {

  }
}


