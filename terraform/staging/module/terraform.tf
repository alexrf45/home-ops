terraform {
  required_providers {
    proxmox = {
      source  = "bpg/proxmox"
      version = "0.69.0"
    }
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.7.0"
    }
    flux = {
      source  = "fluxcd/flux"
      version = "1.4.0"
    }

  }
}

