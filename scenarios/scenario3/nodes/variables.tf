variable "net_address" {}
variable "ecs_flavor" {}
variable "ecs_image" {}
variable "bastion_sec_group_id" {}
variable "network_id" {}
variable "subnet_id" {}
variable "scenario" {}
variable "key_pair_name" {}
variable "region" { default = "eu-de" }
variable "availability_zones" {
    type    = list(string)
    default = ["eu-de-01", "eu-de-02","eu-de-03"]
}
variable "nodes_count" { default = 3 }
variable "disc_volume" {
  type    = number
  default = 5
}
variable "volume_types" {
  type    = list(string)
  default = ["SATA", "SAS", "SSD"]
}

locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
}
