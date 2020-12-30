variable "key_pair" {
  type = object({
    key_name : string
    public_key : string
  })
}
variable "name" {
  default = "bastion"
}
variable "availability_zone" {
  default = "eu-de-01"
}
variable "ecs_flavor" {}
variable "bastion_image" {}
variable "bastion_eip" { default = "" }
variable "network" {}
variable "subnet" {}
variable "router" {}
variable "volume_bastion" {
  type    = number
  default = 10
}
variable "scenario" {}

locals {
  bastion_local_ip = cidrhost(var.subnet.cidr, 2)
}
