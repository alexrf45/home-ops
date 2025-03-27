terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.7.0"
    }
    # flux = {
    #   source  = "fluxcd/flux"
    #   version = "1.4.0"
    # }
    helm = {
      source  = "hashicorp/helm"
      version = "2.17.0"
    }

  }
}

