variable "username" {}
variable "password" {}
variable "region" {}
variable "tenant_name" {}
variable "default_az" {}
variable "domain_name" {}
variable "default_flavor" {}
variable "debian_image" {}
variable "addr_3_octets" {}
variable "postfix" {}
variable "nodes_count" {}
variable "public_key" {
  default = ""
}
variable "bastion_eip" {
  default = "80.158.7.120"
}
