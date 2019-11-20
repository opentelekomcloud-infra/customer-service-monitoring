
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
  network        = module.network.network
  nodes_count    = var.nodes_count
}

output "out-scn3_5_target_fip" {
  value = module.resources.target_fip
}

output "out-out-scn3_5_initiator_fip" {
  value = module.resources.initiator_fip
}