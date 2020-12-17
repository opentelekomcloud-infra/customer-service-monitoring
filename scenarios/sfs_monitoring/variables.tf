variable "availability_zone" {}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "addr_3_octets" {}
variable "scenario" {}
variable "public_key" {
  default = ""
}
variable "network_id" {}
variable "router_id" {}
variable "subnet_id" {}
variable "disc_volume" {
  type    = number
  default = 10
}