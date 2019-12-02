variable "username" {}
variable "password" {}
variable "region" {}
variable "tenant_name" {}
variable "availability_zone" {}
variable "domain_name" {}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "addr_3_octets" { default = "192.168.0" }
variable "scenario" {}
variable "nodes_count" {
  type    = number
  default = 2
}
variable "public_key" { default = "" }
