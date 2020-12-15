variable "target_availability_zone" {
  default = "eu-de-01"
}
variable "initiator_availability_zone" {
  default = "eu-de-03"
}
variable "scenario" {
  default = "sfs"
}
variable "ecs_flavor" {
  default = "s2.large.2"
}
variable "ecs_image" {
  default = "Standard_Debian_10_latest"
}
variable "volume_type" {
  default = "SATA"
}
variable "public_key" {}
variable "subnet_id" {}
variable "network_id" {}
variable "router_id" {}
variable "addr_3" {
  default = "192.168.4"
}
variable "disk_volume" {
  type    = number
  default = 10
}
