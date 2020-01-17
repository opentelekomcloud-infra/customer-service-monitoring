
locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  prefix           = "${local.workspace_prefix}${var.scenario}"
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}kp_${var.scenario}"
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
  scenario          = var.scenario
}

module "loadbalancer" {
  source = "../modules/loadbalancer"

  instances             = module.resources.instances
  net_address           = var.addr_3_octets
  scenario              = var.scenario
  subnet_id             = module.network.subnet.id
  workspace_prefix      = local.workspace_prefix
}

module "resources" {
  source = "./resources"

  ecs_flavor            = var.ecs_flavor
  host_image            = var.host_image
  net_address           = var.addr_3_octets
  nodes_count           = var.nodes_count
  bastion_local_ip      = module.bastion.bastion_ip
  bastion_sec_group_id  = module.bastion.bastion_group_id
  network_id            = module.network.network.id
  router_id             = module.network.router.id
  subnet_id             = module.network.subnet.id
  prefix                = local.prefix
  availability_zone     = var.availability_zone
  key_pair              = local.key_pair
  scenario              = var.scenario
  bastion_eip           = opentelekomcloud_networking_floatingip_v2.server_fip.address
  lb_monitor            = module.loadbalancer.monitor
  lb_pool               = module.loadbalancer.pool
}

output "out-scn4_lb_fip" {
  value = module.loadbalancer.loadbalancer_fip
}

output "out-scn4_bastion_fip" {
  value = opentelekomcloud_networking_floatingip_v2.server_fip.address
}
