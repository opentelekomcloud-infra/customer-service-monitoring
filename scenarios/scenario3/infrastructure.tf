
locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  prefix           = "${local.workspace_prefix}${var.scenario}"
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.prefix}_kp"
  }
}

module "network" {
  source = "../modules/public_router"

  addr_3_octets = var.addr_3_octets
  prefix        = local.prefix
}

resource "opentelekomcloud_networking_floatingip_v2" "server_fip" {
  pool = "admin_external_net"
}

module "bastion" {
  source = "../modules/bastion"

  bastion_image     = var.ecs_image
  bastion_eip       = opentelekomcloud_networking_floatingip_v2.server_fip.address
  ecs_flavor        = var.ecs_flavor
  key_pair          = local.key_pair
  network           = module.network.network
  subnet            = module.network.subnet
  router            = module.network.router
  name              = "${local.workspace_prefix}server"
  availability_zone = var.availability_zone
  scenario          = var.scenario
}

module "resources" {
  source = "./resources"

  bastion_vm_id     = module.bastion.bastion_vm_id
  availability_zone = var.availability_zone
}

output "out-scn3_server_fip" {
  value = opentelekomcloud_networking_floatingip_v2.server_fip.address
}
