
locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  prefix = "${local.workspace_prefix}${var.postfix}"
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

  debian_image   = var.debian_image
  bastion_eip    = opentelekomcloud_networking_floatingip_v2.server_fip.address
  default_flavor = var.default_flavor
  key_pair       = local.key_pair
  network        = module.network.network
  subnet         = module.network.subnet
  router         = module.network.router
  name           = "${local.prefix}_server"
}

module "resources" {
  source = "./resources"

  default_flavor         = var.default_flavor
  debian_image           = var.debian_image
  net_address            = var.addr_3_octets
  key_pair_name          = local.key_pair.key_name
  nodes_count            = var.nodes_count
  bastion_local_ip       = module.bastion.bastion_ip
  loadbalancer_local_ip  = "${var.addr_3_octets}.3"
  bastion_sec_group_id   = module.bastion.basion_group_id
  network_id             = module.network.network.id
  subnet_id              = module.network.subnet.id
  loadbalancer_public_ip = var.loadbalancer_eip
}

output "out-scn4_lb_fip" {
  value = module.resources.scn4_lb_fip
}

output "out-scn4_bastion_fip" {
  value = var.bastion_eip
}
