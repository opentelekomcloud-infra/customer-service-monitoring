variable "region" {}
variable "availability_zone" {}
variable "ecs_flavor" {}
variable "bastion_image" {}
variable "ecs_image" {}
variable "addr_3_octets" {
  default = "192.168.5"
}
variable "scenario" {}
variable "public_key" {
  default = ""
}
variable "controller_ip" {
  default = ""
}
variable "disc_volume" {}
variable "subnet_id" {}
variable "network_id" {}
variable "router_id" {}
