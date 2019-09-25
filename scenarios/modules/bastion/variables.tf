variable "key_pair" {
  type = object({
    key_name : string
    public_key : string
  })
}
variable "name" {
  default = "bastion"
}
variable "router_id" {}
variable "default_flavor" {}
variable "debian_image" {}
variable "bastion_eip" {}
variable "network_id" {}
variable "subnet_id" {}
variable "addr_3_octets" {}
variable "volume_bastion" {
  type    = number
  default = 10
}
