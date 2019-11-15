
locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  prefix           = "${local.workspace_prefix}${var.postfix}"
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

module "resources" {
  source = "./resources"
  prefix         = local.prefix
  debian_image   = var.debian_image
  default_az     = var.default_az
  default_flavor = var.default_flavor
  disc_volume    = var.disc_volume
  key_pair       = local.key_pair
  net_address    = var.addr_3_octets
  subnet         = module.network.subnet
  nodes_count    = var.nodes_count
}
