terraform {
  required_providers {
    hcloud = {
      source  = "hetznercloud/hcloud"
      version = "1.47.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    cloudinit = {
      source  = "hashicorp/cloudinit"
      version = "~> 2.3.3"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.34.0"
    }


  }
  backend "s3" {

  }
}

module "vps" {
  source       = "github.com/alexrf45/lab.git//archive/hetzner_vps_cf_dns?ref=v1.0.0"
  hcloud_token = var.hcloud_token
  username     = "sean"
  api_token    = var.api_token
  zone_id      = var.zone_id
  ssh_key_path = "~/.ssh/vps.pub"
  image        = "debian-12"
  server_name  = "thebes"
  server_type  = "cpx11"
  location     = "ash-dc1"
  dns_ptr      = "thebes.fr3d.dev"
}


variable "hcloud_token" {
  sensitive = true
  type      = string
}

variable "api_token" {
  description = "cloudflare token"
  type        = string
}

variable "zone_id" {
  description = "cloudflare zone id"
  type        = string
}


output "ipv4_address" {
  value = module.vps.ipv4_address
}
