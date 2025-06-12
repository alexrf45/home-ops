
terraform {
  backend "s3" {

  }
}

module "app" {
  source         = "git@github.com:alexrf45/lab.git//archive/k3s-cloudflare-tunnel?ref=v1.0.0"
  env            = "prod"
  app            = "vw"
  subdomain      = "dev.ext"
  site_domain    = "fr3d.dev"
  namespace      = "vaultwarden"
  service_domain = "http://dev-vaultwarden:80"
  replicas       = 1
  account_id     = var.account_id
  api_token      = var.api_token
}
