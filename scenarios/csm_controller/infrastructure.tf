resource "opentelekomcloud_networking_floatingip_v2" "controller_eip" {
  count = var.controller_eip == "" ? 1 : 0
}

locals {
  workspace_prefix = terraform.workspace == "default" ? "" : terraform.workspace
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}_kp_${var.scenario}"
  }
  c_eip = var.controller_eip == "" ? opentelekomcloud_networking_floatingip_v2.controller_eip[0].address : var.controller_eip
}

module "network" {
  source = "../modules/public_router"

  addr_3_octets = var.addr_3_octets
  prefix        = "${local.workspace_prefix}_${var.scenario}"
}

module "bastion" {
  source = "../modules/bastion"

  bastion_image = var.ecs_image
  ecs_flavor    = var.ecs_flavor

  key_pair = local.key_pair
  network  = module.network.network
  subnet   = module.network.subnet
  router   = module.network.router
  name     = local.workspace_prefix
  scenario = var.scenario

  availability_zone = var.availability_zone
  bastion_eip       = local.c_eip
}

output "csm_controller_fip" {
  value = local.c_eip
}

output "subnet" {
  value = module.network.subnet.id
}

output "network" {
  value = module.network.network.id
}

output "router" {
  value = module.network.router.id
}
