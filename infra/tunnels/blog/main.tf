
terraform {
  backend "s3" {

  }
}

module "app" {
  source         = "git@github.com:alexrf45/lab.git//archive/k3s-cloudflare-tunnel?ref=v1.0.0"
  env            = "prod"
  app            = "blog"
  subdomain      = "blog"
  site_domain    = "fr3d.dev"
  namespace      = "blog"
  service_domain = "http://prod-blog-musings:80"
  replicas       = 2
  account_id     = var.account_id
  api_token      = var.api_token
}
