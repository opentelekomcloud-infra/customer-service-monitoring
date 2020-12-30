variable "target_availability_zone" {}
variable "initiator_availability_zone" {}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "scenario" {}
variable "public_key" {}
variable "subnet_id" {}
variable "network_id" {}
variable "router_id" {}
variable "disc_volume" {
  type    = number
  default = 10
}
variable "network_cidr" {
  description = "CIDR of network used for all scenarios"
}

locals {
  scenario_subnet = cidrsubnet(var.network_cidr, 8, 4)
}
