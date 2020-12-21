variable "prefix" {}
variable "region" {}
variable "availability_zone" {}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "addr_3" {}

variable "public_key" {}
variable "network_id" {}
variable "subnet_id" {}
variable "router_id" {}
variable "disc_volume" {
  type    = number
  default = 10
}