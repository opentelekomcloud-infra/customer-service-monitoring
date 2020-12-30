variable "scenario" {}
variable "region" { default = "eu-de" }
variable "availability_zone" {}
variable "ecs_flavor" {}
variable "ecs_image" {
  default = "Standard_Debian_10_latest"
}
variable "subnet_cidr" {}

variable "key_pair" {}
variable "network_id" {}
variable "subnet_id" {}
variable "router_id" {}
variable "disc_volume" {
  type    = number
  default = 10
}
locals {
  workspace_prefix = terraform.workspace == "default" ? "" : terraform.workspace
}
