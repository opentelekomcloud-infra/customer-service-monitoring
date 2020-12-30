variable "region" { default = "eu-de" }
variable "availability_zone" {}
variable "ecs_flavor" { default = "s2.large.2" }
variable "ecs_image" { default = "Standard_Debian_10_latest" }
variable "scenario" {}
variable "psql_version" {}
variable "psql_port" {}
variable "psql_password" {}
variable "public_key" {}
variable "network_id" {}
variable "subnet_id" {}
variable "router_id" {}
variable "network_cidr" {
  description = "CIDR of network used for all scenarios"
}

locals {
  scenario_subnet = cidrsubnet(network_cidr, 24, 2)  # using same subnet, as csm_controller
}
