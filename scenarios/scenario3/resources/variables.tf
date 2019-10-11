variable "default_flavor" {}
variable "debian_image" {}
variable "network" {}
variable "subnet" {}
variable "router" {}
variable "postfix" {}
variable "name" {}
variable "net_address" {}
variable "volume_server" {
  type    = number
  default = 10
}
variable "public_key" {
  default = null
}
variable "volume_type" {
  type    = list(string)
  default = ["SATA", "SAS", "SSD"]
}
