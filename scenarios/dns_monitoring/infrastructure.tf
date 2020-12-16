locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}_kp_${var.scenario}"
  }
}

module "resources" {
  source = "../resources"

  bastion_image     = var.ecs_image
  bastion_eip       = .bastion_fip.address
  ecs_flavor        = var.ecs_flavor
  key_pair          = local.key_pair
  network           = module.network.network
  subnet            = module.network.subnet
  router            = module.network.router
  name              = "${local.workspace_prefix}bastion"
  availability_zone = var.availability_zone
  scenario          = var.scenario
}

output "dns_instance_fip" {
  value = module.nodes.dns_instance_address
}

output "dns_record_name" {
  value = module.nodes.dns_record
}
