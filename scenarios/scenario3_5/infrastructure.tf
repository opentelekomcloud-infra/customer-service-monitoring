
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
  key_pair      = local.key_pair
  network       = module.network.network
  subnet        = module.network.subnet
  router        = module.network.router
  name          = "${local.workspace_prefix}bastion"
  scenario      = var.scenario

  availability_zone = var.target_availability_zone
  bastion_eip       = opentelekomcloud_networking_floatingip_v2.bastion_public_ip.address
}

module "resources" {
  source = "./resources"

  ecs_image                   = var.ecs_image
  initiator_availability_zone = var.initiator_availability_zone
  target_availability_zone    = var.target_availability_zone
  ecs_flavor                  = var.ecs_flavor
  disc_volume                 = var.disc_volume
  key_pair                    = local.key_pair
  net_address                 = var.addr_3_octets
  subnet                      = module.network.subnet
  network                     = module.network.network
  scenario                    = var.scenario
}

output "out-scn3_5_target_fip" {
  value = module.resources.target_fip
}

output "out-scn3_5_initiator_fip" {
  value = module.resources.initiator_fip
}

output "out-scn3_5_iscsi_device_name" {
  value = module.resources.device_name
}
