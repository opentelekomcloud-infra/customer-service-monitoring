variable "username" {}
variable "password" {}
variable "postfix" {}
variable "net_address" {}
variable "region" {}
variable "default_az" {}
variable "domain_name" {}
variable "tenant_name" {}
variable "default_flavor" {}
variable "vm_image" {}
variable "psql_version" {}

variable "psql_port" {}
variable "psql_password" {}
variable "public_key" {
  default = null
}
