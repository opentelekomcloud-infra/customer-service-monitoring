
locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}kp_${var.scenario}"
  }
}

module "network" {
  source = "../modules/public_router"

  addr_3_octets = var.addr_3_octets
  prefix        = "${local.workspace_prefix}${var.scenario}"
}

resource "opentelekomcloud_networking_floatingip_v2" "bastion_public_ip" {}

module "bastion" {
  source = "../modules/bastion"

  bastion_image = var.ecs_image
  ecs_flavor    = var.ecs_flavor

  key_pair = local.key_pair
  network  = module.network.network
  subnet   = module.network.subnet
  router   = module.network.router
  name     = "${local.workspace_prefix}bastion"
  scenario = var.scenario

  availability_zone = var.availability_zone
  bastion_eip       = opentelekomcloud_networking_floatingip_v2.bastion_public_ip.address
}

module "postgresql" {
  source = "../modules/postgresql"

  availability_zone = var.availability_zone
  instance_name     = "scn2-db"

  network_id  = module.network.network.id
  subnet_id   = module.network.subnet.id
  subnet_cidr = module.network.subnet.cidr

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
