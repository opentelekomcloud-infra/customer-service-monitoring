variable "region" { default = "eu-de" }
variable "availability_zone" { default = "eu-de-03" }
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "scenario" {}
variable "public_key" { default = "" }
variable "controller_eip" { default = "" }
variable "kms_key" {}
variable "network_cidr" {
  description = "CIDR of network used for all scenarios"
}

locals {
  scenario_subnet = var.network_cidr
}
