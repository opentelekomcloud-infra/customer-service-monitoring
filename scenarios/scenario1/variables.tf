variable "username" {}
variable "password" {}
variable "region" {}
variable "tenant_name" {}
variable "default_az" {}
variable "domain_name" {}
variable "default_flavor" {}
variable "debian_image" {}
variable "addr_3_octets" { default = "192.168.0" }
variable "postfix" {}
variable "nodes_count" {
  type    = number
  default = 2
}
variable "public_key" { default = "" }
variable "bastion_eip" {}
variable "loadbalancer_eip" {}
