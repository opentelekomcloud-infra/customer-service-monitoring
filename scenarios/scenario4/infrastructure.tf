
locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  prefix           = "${local.workspace_prefix}${var.postfix}"
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}kp_${var.postfix}"
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

  name          = "${local.prefix}_bastion"
  bastion_image = var.bastion_image
  ecs_flavor    = var.ecs_flavor
  key_pair      = local.key_pair

  bastion_eip       = opentelekomcloud_networking_floatingip_v2.server_fip.address
  availability_zone = var.availability_zone
  network           = module.network.network
  subnet            = module.network.subnet
  router            = module.network.router
}

module "resources" {
  source = "./resources"

  ecs_flavor            = var.ecs_flavor
  host_image            = var.host_image
  net_address           = var.addr_3_octets
  nodes_count           = var.nodes_count
  bastion_local_ip      = module.bastion.bastion_ip
  loadbalancer_local_ip = "${var.addr_3_octets}.3"
  bastion_sec_group_id  = module.bastion.bastion_group_id
  network_id            = module.network.network.id
  router_id             = module.network.router.id
  subnet_id             = module.network.subnet.id
  prefix                = local.prefix
  availability_zone     = var.availability_zone
  key_pair              = local.key_pair
}

output "out-scn4_lb_fip" {
  value = module.resources.scn4_lb_fip
}

output "out-scn4_bastion_fip" {
  value = opentelekomcloud_networking_floatingip_v2.server_fip.address
}
