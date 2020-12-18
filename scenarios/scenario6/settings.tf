terraform {
  required_providers {
    opentelekomcloud = ">= 1.16.0"
  }
  backend "s3" {
    key      = "terraform_state/scenario6"
    endpoint = "obs.eu-de.otc.t-systems.com"
    bucket   = "obs-csm"
    region   = "eu-de"

    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
  cloud = var.cloud
}

