variable "kms_key_name" {}
variable "key_pair" {}
variable "ecs_image" {}
variable "ecs_flavor" {
  default = ""
}
variable "disc_volume" {}
variable "subnet_id" {
  default = ""
}
variable "network_id" {
  default = ""
}
variable "router_id" {
  default = ""
}
variable "scenario" {
  default = ""
}
variable "availability_zone" {
  default = ""
}
variable "subnet_cidr" {}
