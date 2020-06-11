variable "region" { default = "eu-de" }
variable "az_default" { default = false}
variable "availability_zone" { default = "eu-de-03" }
variable "availability_zones" {
  type        = list(string)
  default     = ["eu-de-01", "eu-de-02", "eu-de-03"]
}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "addr_3_octets" { default = "192.168.0" }
variable "scenario" {}
variable "nodes_count" {}
variable "public_key" { default = "" }
