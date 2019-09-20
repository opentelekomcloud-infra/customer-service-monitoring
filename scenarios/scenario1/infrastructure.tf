terraform {
  required_providers {
    opentelekomcloud = ">= 1.11.0"
  }
  backend "s3" {
    key = "terraform_state/scenario1"
    endpoint =  "obs.eu-de.otc.t-systems.com"
    bucket = "obs-csm"
    region = "eu-de"
    skip_region_validation = true
    skip_credentials_validation = true
  }
}

variable "username" {}
variable "password" {}
variable "region" {}
variable "tenant_name" {}
variable "default_az" {}
variable "domain_name" {}
variable "default_flavor" {}
variable "debian_image" {}
variable "net_address" {}
variable "postfix" {}
variable "nodes_count" {}
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
  debian_image = var.debian_image
  net_address = var.net_address
  public_key = var.public_key
  postfix = var.postfix
  nodes_count = var.nodes_count
  bastion_local_ip = "${var.net_address}.2"
  loadbalancer_local_ip= "${var.net_address}.3"
}

output "out-scn1_lb_fip" {
  value = module.resources.scn1_lb_fip
}

output "out-scn1_bastion_fip" {
  value = module.resources.scn1_bastion_fip
}

# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
  user_name = var.username
  password = var.password
  domain_name = var.domain_name
  tenant_name = var.tenant_name
  auth_url = "https://iam.eu-de.otc.t-systems.com:443/v3"
}
