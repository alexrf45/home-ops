
module "home-base" {
  source              = "git@github.com:alexrf45/lab.git//cf-tunnel"
  env                 = var.env
  app                 = var.app
  api_token           = var.api_token
  account_id          = var.account_id
  zone_id             = var.zone_id
  domain              = var.domain
  tunnel_name         = var.tunnel_name
  primary_subdomain   = var.primary_subdomain
  primary_service_url = var.primary_service_url
  home_services       = var.home_services

}
