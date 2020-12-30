variable "region" { default = "eu-de" }
variable "use_single_az" { default = false }
variable "availability_zones" {
  type    = list(string)
  default = ["eu-de-01", "eu-de-02", "eu-de-03"]
}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "scenario" {}
variable "nodes_count" {}
variable "public_key" { default = "" }
variable "subnet_id" {}
variable "network_id" {}
variable "router_id" {}
variable "network_cidr" {
  description = "CIDR of network used for all scenarios"
}

locals {
  scenario_subnet = cidrsubnet(var.network_cidr, 8, 1)
}
