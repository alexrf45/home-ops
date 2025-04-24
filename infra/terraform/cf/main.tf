terraform {
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 5"
    }

  }
  backend "s3" {

  }
}



provider "cloudflare" {
  api_key = var.api_key
  email   = var.email
}

variable "email" {
  description = "email address for cf account"
  sensitive   = true
}

variable "api_key" {
  description = "cf global api token"
  sensitive   = true
}

variable "account_id" {
  description = "account id of cf zone"
  sensitive   = true
}

variable "env" {
  description = "system enviornment"
  type        = string
  default     = "dev"
}
variable "zone_id" {
  description = "api zone id"
  type        = string
  sensitive   = true
}

# resource "cloudflare_api_token" "this" {
#   name = var.env
#   policy {
#     effect = "allow"
#     permission_groups = 
#     resources = {
#       var.zone_id : "*", 
#     }
#   }
# }

data "cloudflare_api_token_permission_groups_list" "example_api_token_permission_groups_list" {
  max_items = 200
}
data "cloudflare_account_api_token_permission_groups" "example_account_api_token_permission_groups" {
  account_id = var.account_id
}

output "groups" {
  value = data.cloudflare_api_token_permission_groups_list.example_api_token_permission_groups_list.result[*]
}


output "groups2" {
  value = [for group in data.cloudflare_api_token_permission_groups_list.example_api_token_permission_groups_list.result : group.name]
}

