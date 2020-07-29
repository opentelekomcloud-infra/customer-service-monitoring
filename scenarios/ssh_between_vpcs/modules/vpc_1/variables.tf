variable "vpc_1_cidr" {}
variable "ecs_image" {}
variable "ecs_flavor" {}
variable "availability_zone" {}
variable "volume_ecs" {
  type    = number
  default = 10
}
variable "scenario" {}