variable "region" { default = "eu-de" }
variable "availability_zone" { default = "eu-de-03" }
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "scenario" {}
variable "public_key" { default = "" }
variable "controller_eip" { default = "" }
variable "network_cidr" {
  description = "CIDR of network used for all scenarios"
  default     = "192.168.0.0/16"
}

locals {
  scenario_subnet = cidrsubnet(network_cidr, 24, 0)
}
