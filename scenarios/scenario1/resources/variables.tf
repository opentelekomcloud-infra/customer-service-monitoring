variable "net_address" {}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "bastion_sec_group_id" {}
variable "network_id" {}
variable "subnet_id" {}
variable "postfix" {}

variable "bastion_local_ip" {}
variable "nodes_count" {}
variable "key_pair_name" {}
variable "disc_volume" {
  type    = number
  default = 5
}

variable "loadbalancer_local_ip" {}

locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
}
