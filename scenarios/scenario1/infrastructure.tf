
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

module "nodes" {
  source = "../modules/ecs_node"

  ecs_flavor        = var.ecs_flavor
  ecs_image         = var.ecs_image
  key_pair_name     = local.key_pair.key_name
  nodes_count       = var.nodes_count
  scenario          = var.scenario
  use_single_az     = var.use_single_az
  availability_zone = var.availability_zone

  net_address          = var.addr_3_octets
  network_id           = module.network.network.id
  subnet_id            = module.network.subnet.id
  bastion_sec_group_id = module.bastion.bastion_group_id
}

module "loadbalancer" {
  source = "../modules/loadbalancer"

  instances        = module.nodes.instances
  net_address      = var.addr_3_octets
  scenario         = var.scenario
  subnet_id        = module.network.subnet.id
  workspace_prefix = local.workspace_prefix
}

output "scn1_lb_fip" {
  value = module.loadbalancer.loadbalancer_fip
}

output "scn1_bastion_fip" {
  value = opentelekomcloud_networking_floatingip_v2.bastion_public_ip.address
}

output "scn1_ecs_local_ips" {
  value = [for instance in module.nodes.instances : instance.access_ip_v4]
}
