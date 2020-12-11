variable "addr_3_octets" {
  default = "192.168.0"
}
variable "public_key" {
  default = ""
}
variable "disc_volume" {
  type    = number
  default = 10
}
variable "target_availability_zone" {
  default = "eu-de-01"
}
variable "initiator_availability_zone" {
  default = "eu-de-03"
}
variable "scenario" {
  default = "sfs_monitoring"
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
variable "key_pair_name" {}
variable "subnet" {}
variable "network" {}
variable "router" {}
variable "net_address" {}
