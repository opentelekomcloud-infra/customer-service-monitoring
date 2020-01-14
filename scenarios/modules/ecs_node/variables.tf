variable "net_address" {}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "bastion_sec_group_id" {}
variable "network_id" {}
variable "subnet_id" {}
variable "scenario" {}
variable "nodes_count" {}
variable "key_pair_name" {}
variable "availability_zone" { default = "eu-de-03" }
variable "disc_volume" {
  type    = number
  default = 5
}

locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
}
