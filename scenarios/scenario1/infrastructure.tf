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
variable "postfix" {}
variable "public_key" {
  default = ""
}

module "resources" {
  source = "./resources"

  username = var.username
  password = var.password
  region = var.region
  tenant_name = var.tenant_name
  default_az = var.default_az
  domain_name = var.domain_name
  default_flavor = var.default_flavor
  centos_image = var.centos_image
  net_address = var.net_address
  public_key = var.public_key
  postfix = var.postfix
  ecs_local_ips = [
    "${var.net_address}.10",
    "${var.net_address}.11"
  ]
}

output "out-scn1_lb_fip" {
  value = module.resources.scn1_lb_fip
}

# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
  user_name = var.username
  password = var.password
  domain_name = var.domain_name
  tenant_name = var.tenant_name
  auth_url = "https://iam.eu-de.otc.t-systems.com:443/v3"
}
