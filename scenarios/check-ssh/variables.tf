variable "availability_zone"{}
variable "ecs_flavor"{}
variable "ecs_image" {}
variable "scenario" {}
variable "addr_3_octets" {}
variable "public_key" {}
variable "volume_ecs" {
  type    = number
  default = 10
}

