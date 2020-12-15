locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}_kp_${var.scenario}"
  }
}

module "resources" {
  source = "./resources"

  ecs_image                   = var.ecs_image
  initiator_availability_zone = var.availability_zone
  ecs_flavor                  = var.ecs_flavor
  disc_volume                 = var.disc_volume
  key_pair_name               = local.key_pair.key_name


  net_address = var.addr_3
  subnet      =
  network     =
  router      =
  scenario    = var.scenario
}

output "sfs_instance_ip" {
  value = module.resources.sfs_instance_ip
}

output "sfs_data" {
  value = module.resources.sfs
}