variable "env" {
  description = "code/app environement"
  type        = string
  validation {
    condition = anytrue([
      var.env == "dev",
      var.env == "stage",
      var.env == "prod",
      var.env == "testing"
    ])
    error_message = "Please use one of the approved environement names: dev, stage, prod, testing"
  }
}

variable "app" {
  description = "app or project name"
  type        = string
  default     = "demo"
}

variable "account_id" {
  description = "Cloudflare account ID"
  type        = string
  sensitive   = true
}

variable "api_token" {
  description = "cloudflare api token"
  type        = string
  sensitive   = true
}

variable "zone_id" {
  description = "Cloudflare zone ID for the domain"
  type        = string
  sensitive   = true
}

variable "domain" {
  description = "Domain name for the services behind tunnel"
  type        = string
  sensitive   = true
}

variable "tunnel_name" {
  description = "Name of the Cloudflare tunnel"
  type        = string
  default     = "home-tunnel"
}

variable "primary_subdomain" {
  description = "Subdomain for primary service"
  type        = string
  default     = "home-lab"
}

variable "primary_service_url" {
  description = "Primary Service URL (e.g., http://service:8000 or https://internal.service.com)"
  type        = string
  default     = "http://localhost:8000"
}


variable "home_services" {
  description = "List of services with their internal address"
  type = list(object({
    subdomain   = string
    service_url = string
  }))
  default = [
    {
      subdomain   = "web1"
      service_url = "http://web1:8080"
    },
    {
      subdomain   = "web2"
      service_url = "http://web2:8080"
    },
    {
      subdomain   = "api"
      service_url = "http://api:8080"
    },
    {
      subdomain   = "db1"
      service_url = "http://db1:9999"
    }
  ]
}

