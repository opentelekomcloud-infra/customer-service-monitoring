locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}_kp_${var.scenario}"
  }
}

resource "opentelekomcloud_compute_keypair_v2" "kp" {
  name       = local.key_pair.key_name
  public_key = local.key_pair.public_key
}

module "resources" {
  source = "./resources"

  ecs_image                   = var.ecs_image
  initiator_availability_zone = var.initiator_availability_zone
  target_availability_zone    = var.target_availability_zone
  ecs_flavor                  = var.ecs_flavor
  disc_volume                 = var.disc_volume
  key_pair_name               = local.key_pair.key_name


  net_address    = var.addr_3_octets
  subnet_id      = var.subnet_id
  network_id     = var.network_id
  router_id      = var.router_id
  scenario       = var.scenario
}

output "iscsi_initiator_instance_ip" {
  value = module.resources.initiator_instance_ip
}

output "iscsi_target_instance_ip" {
  value = module.resources.target_instance_ip
}
