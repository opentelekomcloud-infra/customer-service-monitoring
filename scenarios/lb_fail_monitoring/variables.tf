variable "availability_zone" {}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "addr_3_octets" {}
variable "scenario" {}
variable "nodes_count" {
  type    = number
  default = 2
}
variable "public_key" {
  default = ""
}
variable "subnet_id" {}
variable "network_id" {}
variable "router_id" {}
