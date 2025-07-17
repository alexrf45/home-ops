terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = ">= 0.78.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.8.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.2"
    }
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.17.0"
    }

  }
}

