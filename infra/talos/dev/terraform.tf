terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.77.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.8.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }

  }
  backend "s3" {

  }
}

