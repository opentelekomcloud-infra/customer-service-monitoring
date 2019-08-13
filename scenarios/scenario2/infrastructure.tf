terraform {
  required_providers {
    opentelekomcloud = ">= 1.11.0"
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

module "resources" {
  source = "./resources"

  username = var.username
  password = var.password
  postfix = var.postfix
  net_address = var.net_address
  region = var.region
  default_az = var.region
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
}

# Configure the OpenTelekomCloud Provider
provider "opentelekomcloud" {
  user_name = var.username
  password = var.password
  domain_name = "OTC00000000001000000447"
  tenant_name = "eu-de_rus"
  auth_url = "https://iam.eu-de.otc.t-systems.com:443/v3"
}
