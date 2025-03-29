provider "aws" {}

provider "onepassword" {
  service_account_token = var.token
}
