variable "region" {}
variable "availability_zone" {}
variable "ecs_flavor" {}
variable "host_image" {}
variable "scenario" {}
variable "public_key" {
  default = ""
}
variable "controller_ip" {
  default = ""
}
variable "disc_volume" {
  type    = number
  default = 10
}
variable "subnet_id" {}
variable "network_id" {}
variable "router_id" {}
variable "ecs_image" {}
variable "network_cidr" {
  description = "CIDR of network used for all scenarios"
  default     = "192.168.0.0/16"
}

locals {
  scenario_subnet = cidrsubnet(network_cidr, 24, 5)
}
