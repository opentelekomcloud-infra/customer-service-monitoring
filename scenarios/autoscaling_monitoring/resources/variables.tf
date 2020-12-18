variable "net_address" {}
variable "ecs_flavor" {}
variable "host_image" {}
variable "bastion_sec_group_id" {}
variable "network_id" {}
variable "subnet_id" {}
variable "router_id" {}
variable "bastion_local_ip" {}
variable "bastion_eip" {}
variable "nodes_count" {}
variable "prefix" { default = "prefix" }
variable "scenario" {}
variable "availability_zone" {}
variable "disc_volume" {
  type    = number
  default = 5
}
variable "lb_monitor" {}
variable "lb_pool" {}
variable "key_pair" {
  type = object({
    key_name : string
    public_key : string
  })
}
