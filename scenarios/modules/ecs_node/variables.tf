variable "node_local_ip" {}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "network_id" {}
variable "subnet_id" {}
variable "scenario" {}
variable "nodes_count" {}
variable "key_pair_name" {}
variable "use_single_az" {
  description = "if set to true, single availability_zone is used"
  type        = bool
  default     = true
}
variable "availability_zone" { default = "eu-de-03" }
variable "availability_zones" {
  type    = list(string)
  default = ["eu-de-01", "eu-de-02", "eu-de-03"]
}
variable "disc_volume" {
  type    = number
  default = 5
}
