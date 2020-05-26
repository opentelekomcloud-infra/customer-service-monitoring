terraform {
  required_providers {
    opentelekomcloud = ">= 1.16.0"
  }
}

# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
    cloud = "devstack"
}
