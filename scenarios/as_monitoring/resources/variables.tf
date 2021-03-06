variable "subnet_cidr" {}
variable "ecs_flavor" {}
variable "host_image" {}
variable "ecs_image" {}
variable "network_id" {}
variable "subnet_id" {}
variable "router_id" {}
variable "controller_ip" {}
variable "scenario" {}
variable "availability_zone" {}
variable "disc_volume" {}
variable "lb_monitor" {}
variable "lb_pool" {}
variable "key_pair" {}
variable "group_tag" {
  default = "gatewayed"
}
