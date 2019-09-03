terraform {
  required_providers {
    opentelekomcloud = ">= 1.11.0"
  }
  backend "s3" {
    key = "terraform_state/scenario2"
    endpoint =  "obs.eu-de.otc.t-systems.com"
    bucket = "obs-csm"
    region = "eu-de"
    skip_region_validation = true
    skip_credentials_validation = true
  }
}

variable "username" {}
variable "password" {}
variable "postfix" {}
variable "net_address" {}
variable "region" {}
variable "default_az" {}
variable "domain_name" {}
variable "tenant_name" {}
variable "default_flavor" {}
variable "centos_image" {}

variable "psql_port" {}
variable "psql_password" {}
variable "psql_version" {}
variable "psql_username" {}
variable "psql_flavor" {}
variable "public_key" {
  default = null
}

module "resources" {
  source = "./resources"

  username = var.username
  password = var.password
  postfix = var.postfix
  net_address = var.net_address
  region = var.region
  default_az = var.default_az
  domain_name = var.domain_name
  tenant_name = var.tenant_name
  default_flavor = var.default_flavor
  centos_image = var.centos_image
  psql_port = var.psql_port
  psql_password = var.psql_password
  psql_version = var.psql_version
  psql_username = var.psql_username
  psql_flavor = var.psql_flavor
  ecs_local_ip = "${var.net_address}.10"
  public_key = var.public_key
}

output "out-scn2_public_ip" {
  value = module.resources.scn2_eip
}
output "out-db_password" {
  value = module.resources.db_password
  sensitive = true
}
output "out-db_username" {
  value = module.resources.db_username
}
output "out-db_address" {
  value = module.resources.db_address
}

# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
  user_name = var.username
  password = var.password
  domain_name = "OTC00000000001000000447"
  tenant_name = "eu-de_rus"
  auth_url = "https://iam.eu-de.otc.t-systems.com:443/v3"
}
