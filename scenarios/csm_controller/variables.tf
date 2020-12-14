variable "region" { default = "eu-de" }
variable "availability_zone" { default = "eu-de-03" }
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "addr_3_octets" { default = "192.168.0" }
variable "scenario" {}
variable "public_key" { default = "" }
variable "controller_eip" { default = "" }