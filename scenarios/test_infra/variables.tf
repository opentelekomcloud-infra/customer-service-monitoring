variable "username" {}
variable "password" {}
variable "region" {}
variable "tenant_name" {}
variable "default_az" {}
variable "domain_name" {}
variable "image_name" {}
variable "image_visibility" {
  default = "private"
}
variable "flavour" {
  default = "s2.large.2"
}
variable "public_key" {}

locals {
  prefix = "test_host"
}
