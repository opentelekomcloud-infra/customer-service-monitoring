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
  disk_volume                 = var.disk_volume
  key_pair                    = local.key_pair

  net_address = var.addr_3_octets
  subnet_id   = var.subnet_id
  network_id  = var.network_id
  router_id   = var.router_id
  scenario    = var.scenario
  volume_type = var.volume_type
}

output "sfs_initiator_instance_ip" {
  value = module.resources.initiator_instance_ip
}

output "sfs_target_instance_ip" {
  value = module.resources.target_instance_ip
}

output "export_path" {
  value = module.resources.path_export_location
}
