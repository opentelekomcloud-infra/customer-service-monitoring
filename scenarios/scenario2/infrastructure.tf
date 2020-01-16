
locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}kp_${var.scenario}"
  }
}

resource "opentelekomcloud_vpc_v1" "vpc" {
  name = "${var.prefix}-vpc"
  cidr = "${var.addr_3_octets}.0/16"
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  name        = "${var.prefix}-subnet"
  cidr        = "${var.addr_3_octets}.0/24"
  gateway_ip  = "${var.addr_3_octets}.1"
  vpc_id      = opentelekomcloud_vpc_v1.vpc.id
  primary_dns = "8.8.8.8"

  depends_on = [
    opentelekomcloud_vpc_v1.vpc
  ]
}

resource "opentelekomcloud_networking_floatingip_v2" "bastion_public_ip" {}

module "bastion" {
  source = "../modules/bastion"

  bastion_image = var.ecs_image
  ecs_flavor    = var.ecs_flavor

  key_pair = local.key_pair
  network  = opentelekomcloud_vpc_v1.vpc.id
  subnet   = opentelekomcloud_vpc_subnet_v1.subnet.id
  router   = opentelekomcloud_vpc_v1.vpc.id
  name     = "${local.workspace_prefix}bastion"
  scenario = var.scenario

  availability_zone = var.availability_zone
  bastion_eip       = opentelekomcloud_networking_floatingip_v2.bastion_public_ip.address
}

module "postgresql" {
  source = "../modules/postgresql"

  availability_zone = var.availability_zone
  instance_name     = "scn2-db"

  network_id  = opentelekomcloud_vpc_v1.vpc.id
  subnet_id   = opentelekomcloud_vpc_subnet_v1.subnet.id
  subnet_cidr = opentelekomcloud_vpc_subnet_v1.subnet.cidr

  psql_version  = var.psql_version
  psql_port     = var.psql_port
  psql_password = var.psql_password
}

output "out-scn2_public_ip" {
  value = opentelekomcloud_networking_floatingip_v2.bastion_public_ip.address
}
output "out-db_password" {
  value     = module.postgresql.db_password
  sensitive = true
}
output "out-db_username" {
  value = module.postgresql.db_username
}
output "out-db_address" {
  value = module.postgresql.db_address
}
