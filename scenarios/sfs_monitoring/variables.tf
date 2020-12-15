variable "availability_zone" {}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "addr_3" { default = "192.168.9" }
variable "scenario" {}
variable "public_key" {}
variable "disc_volume" {
  type    = number
  default = 10
}
