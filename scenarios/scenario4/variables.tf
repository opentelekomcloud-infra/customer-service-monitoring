variable "username" {}
variable "password" {}
variable "region" {}
variable "tenant_name" {}
variable "availability_zone" {}
variable "domain_name" {}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "host_image" {}
variable "addr_3_octets" { default = "192.168.0" }
variable "postfix" {}
variable "public_key" { default = "" }
variable "server_eip" { default = "" }
variable "loadbalancer_eip" {}
variable "bastion_eip" {}
variable "nodes_count" {
  type    = number
  default = 1
}
