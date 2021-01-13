terraform {
  required_providers {
    opentelekomcloud = {
      source  = "opentelekomcloud/opentelekomcloud"
      version = ">= 1.22.0"
    }
  }
  backend "s3" {
    key                         = "terraform_state/hdd_monitoring"
    endpoint                    = "obs.eu-de.otc.t-systems.com"
    bucket                      = "obs-csm"
    region                      = "eu-de"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {}
