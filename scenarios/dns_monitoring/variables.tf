variable "region" {
  default = "eu-de"
}
variable "availability_zone" {
  default = "eu-de-01"
}
variable "ecs_flavor" {
  default = "s2.large.2"
}
variable "ecs_image" {
  default = "Standard_Debian_10_latest"
}
variable "addr_3_octets" {
  default = "192.168.6"
}
variable "scenario" {
  default = "dns_monitoring"
}
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
