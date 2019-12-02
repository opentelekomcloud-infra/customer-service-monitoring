
locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}kp_${var.postfix}"
  }
}

module "network" {
  source = "../modules/public_router"

  addr_3_octets = var.addr_3_octets
  prefix        = "${local.workspace_prefix}${var.postfix}"
}

module "bastion" {
  source = "../modules/bastion"

  bastion_image  = var.ecs_image
  ecs_flavor = var.ecs_flavor

  bastion_eip = var.bastion_eip
  key_pair    = local.key_pair
  network     = module.network.network
  subnet      = module.network.subnet
  router      = module.network.router
  name        = "${local.workspace_prefix}bastion"

  availability_zone = var.availability_zone

  postfix = var.postfix
}

module "resources" {
  source = "./resources"

  ecs_flavor    = var.ecs_flavor
  ecs_image     = var.ecs_image
  key_pair_name = local.key_pair.key_name
  nodes_count   = var.nodes_count
  postfix       = var.postfix

  net_address            = var.addr_3_octets
  network_id             = module.network.network.id
  subnet_id              = module.network.subnet.id
  bastion_local_ip       = module.bastion.bastion_ip
  loadbalancer_local_ip  = "${var.addr_3_octets}.3"
  bastion_sec_group_id   = module.bastion.bastion_group_id
  loadbalancer_public_ip = var.loadbalancer_eip
}

output "out-scn1_lb_fip" {
  value = module.resources.scn1_lb_fip
}

output "out-scn1_bastion_fip" {
  value = var.bastion_eip
}
