
locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
}

module "network" {
  source = "../modules/public_router"

  addr_3_octets = var.addr_3_octets
  prefix        = "${local.workspace_prefix}${var.postfix}"
}

module "resources" {
  source = "./resources"

  debian_image   = var.debian_image
  default_flavor = var.default_flavor
  net_address    = "${var.addr_3_octets}.10"
  public_key     = var.public_key
  network        = module.network.network
  subnet         = module.network.subnet
  router         = module.network.router
  postfix        = var.postfix
  name           = "${local.workspace_prefix}server"
}

output "out-scn3_server_fip" {
  value = module.resources.scn3_server_fip
}