
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

  bastion_local_ip = "${var.addr_3_octets}.2"
  debian_image     = var.debian_image
  bastion_eip      = var.bastion_eip
  default_flavor   = var.default_flavor
  key_pair         = local.key_pair
  nodes_count      = "2"
  addr_3_octets    = var.addr_3_octets
  network_id       = module.network.network_id
  subnet_id        = module.network.subnet_id
  router_id        = module.network.router_id
  name             = "${local.workspace_prefix}bastion"
}

module "resources" {
  source = "./resources"

  default_flavor        = var.default_flavor
  debian_image          = var.debian_image
  net_address           = var.addr_3_octets
  key_pair_name         = local.key_pair.key_name
  nodes_count           = var.nodes_count
  bastion_local_ip      = "${var.addr_3_octets}.2"
  loadbalancer_local_ip = "${var.addr_3_octets}.3"
  bastion_sec_group_id  = module.bastion.basion_group_id
  network_id            = module.network.network_id
  subnet_id             = module.network.subnet_id
}

output "out-scn1_lb_fip" {
  value = module.resources.scn1_lb_fip
}

output "out-scn1_bastion_fip" {
  value = var.bastion_eip
}

