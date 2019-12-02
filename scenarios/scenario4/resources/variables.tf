variable "net_address" {}
variable "ecs_flavor" {}
variable "host_image" {}
variable "bastion_sec_group_id" {}
variable "network_id" {}
variable "subnet_id" {}
variable "router_id" {}
variable "bastion_local_ip" {}
variable "nodes_count" {}
variable "prefix" {}
variable "scenario" {}
variable "availability_zone" {}
variable "disc_volume" {
  type    = number
  default = 5
}
variable "key_pair" {
  type = object({
    key_name : string
    public_key : string
  })
}
variable "loadbalancer_local_ip" {}

locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
}
