variable "region" { default = "eu-de"}
variable "availability_zone" { default = "eu-de-01" }
variable "ecs_flavor" {}
variable "bastion_image" {}
variable "host_image" {}
variable "addr_3_octets" { default = "192.168.0" }
variable "scenario" {}
variable "public_key" { default = "" }
variable "loadbalancer_eip" { default = "" }
variable "bastion_eip" { default = "" }
variable "nodes_count" {
  type    = number
  default = 1
}
