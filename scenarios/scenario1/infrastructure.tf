terraform {
  required_providers {
    opentelekomcloud = ">= 1.11.0"
  }
}

variable "username" {}
variable "password" {}
variable "region" {}
variable "tenant_name" {}
variable "default_az" {}
variable "domain_name" {}
variable "default_flavor" {}
variable "centos_image" {}
variable "net_address" {}
variable "public_key" {
  default = null
}

# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
  user_name = var.username
  password = var.password
  domain_name = var.domain_name
  tenant_name = var.tenant_name
  auth_url = "https://iam.eu-de.otc.t-systems.com:443/v3"
}
