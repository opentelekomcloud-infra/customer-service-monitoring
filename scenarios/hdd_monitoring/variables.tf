variable "region" { default = "eu-de" }
variable "ecs_flavor" { default = "s2.large.2" }
variable "ecs_image" { default = "Standard_Debian_10_latest" }
variable "scenario" { default = "hdd" }
variable "public_key" {}
variable "subnet_id" {}
variable "network_id" {}
variable "router_id" {}
variable "network_cidr" {
  description = "CIDR of network used for all scenarios"
}

locals {
  scenario_subnet = cidrsubnet(network_cidr, 24, 3)
}
