variable "volume_type" { default = "SATA" }
variable "key_pair" {}
variable "ecs_image" {}
variable "ecs_flavor" {}
variable "disc_volume" {}
variable "subnet_id" {}
variable "network_id" {}
variable "router_id" {}
variable "scenario" {}
variable "target_availability_zone" {}
variable "initiator_availability_zone" {}
variable "net_address" {}
locals {
  workspace_prefix = terraform.workspace == "default" ? "" : terraform.workspace
}
