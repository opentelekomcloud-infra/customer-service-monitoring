locals {
  workspace_prefix = terraform.workspace == "default" ? "" : terraform.workspace
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}_kp_${var.scenario}"
  }
}

module "resources" {
  source = "./resources"

  ecs_image                   = var.ecs_image
  initiator_availability_zone = var.initiator_availability_zone
  target_availability_zone    = var.target_availability_zone
  ecs_flavor                  = var.ecs_flavor
  disc_volume                 = var.disc_volume
  key_pair                    = local.key_pair


  subnet_cidr = local.scenario_subnet
  subnet_id   = var.subnet_id
  network_id  = var.network_id
  router_id   = var.router_id
  scenario    = var.scenario
}

output "iscsi_initiator_instance_ip" {
  value = module.resources.initiator_instance_ip
}

output "iscsi_target_instance_ip" {
  value = module.resources.target_instance_ip
}
