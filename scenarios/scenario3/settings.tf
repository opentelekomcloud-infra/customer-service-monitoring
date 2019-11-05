terraform {
  required_providers {
    opentelekomcloud = ">= 1.11.0"
  }

  backend "s3" { # use OBS for remote state
    key                         = "terraform_state/scenario3"
    endpoint                    = "obs.eu-de.otc.t-systems.com"
    bucket                      = "obs-csm"
    region                      = "eu-de"
    skip_region_validation      = true
    skip_credentials_validation = true
  }
}

# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
  user_name   = var.username
  password    = var.password
  domain_name = var.domain_name
  tenant_name = var.tenant_name
  auth_url    = "https://iam.eu-de.otc.t-systems.com:443/v3"
}
