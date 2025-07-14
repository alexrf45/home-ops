terraform {
  required_providers {
    twilio = {
      source  = "twilio/twilio"
      version = "0.18.46"
    }
  }
  backend "s3" {}
}
