variable "region" { default = "eu-de" }
variable "availability_zone" {}
variable "ecs_flavor" { default = "s2.large.2" }
variable "ecs_image" { default = "Standard_Debian_10_latest" }
variable "addr_3" { default = "192.168.0" }
variable "scenario" { default = "rds" }
variable "psql_version" {}
variable "psql_port" {}
variable "psql_password" {}
variable "public_key" {}
variable "network_id" {}
variable "subnet_id" {}
variable "subnet_cidr" {}
variable "router_id" {}
