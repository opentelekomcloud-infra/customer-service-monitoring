variable "ecs_flavor" {}
variable "ecs_image" {}
variable "scenario" {}
variable "nodes_count" {
  type    = number
  default = 2
}
variable "public_key" {
  default = ""
}
variable "subnet_id" {}
variable "network_id" {}
variable "router_id" {}
variable "network_cidr" {
  description = "CIDR of network used for all scenarios"
}

locals {
  scenario_subnet = cidrsubnet(var.network_cidr, 8, 10)
}
