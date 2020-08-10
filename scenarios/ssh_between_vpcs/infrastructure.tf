locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}kp_${var.scenario}"
  }
}

module "vpc_1" {
  source = "./modules/vpc_1"

  key_pair = local.key_pair
  vpc_1_cidr   = "192.168.0"
  ecs_image    = "Standard_Debian_10_latest"
  ecs_flavor   = "s2.large.2"
  availability_zone    = "eu-de-01"
  scenario     = "${var.scenario}"
}

module "vpc_2" {
  source = "./modules/vpc_2"

  key_pair = local.key_pair
  vpc_2_cidr   = "192.169.0"
  ecs_image    = "Standard_Debian_10_latest"
  ecs_flavor   = "s2.large.2"
  availability_zone    = "eu-de-01"
  scenario     = "${var.scenario}"
}


resource "opentelekomcloud_vpc_peering_connection_v2" "peering_connection" {
  name = "${var.scenario}-peering_1_to_2"
  vpc_id = module.vpc_1.vpc_1_id
  peer_vpc_id = module.vpc_2.vpc_2_id
}

resource "opentelekomcloud_vpc_route_v2" "vpc_route" {
  type  = "peering"
  nexthop  = opentelekomcloud_vpc_peering_connection_v2.peering_connection.id
  destination = module.vpc_2.ecs_2_private_ip
  vpc_id = module.vpc_1.vpc_1_id
 }

output "ecs_1_private_ip" {
  value = module.vpc_1.ecs_1_private_ip
}

output "ecs_2_private_ip" {
  value = module.vpc_2.ecs_2_private_ip
}


output "ecs_1_public_ip" {
  value = module.vpc_1.ecs_1_public_ip
}

output "ecs_2_public_ip" {
  value = module.vpc_2.ecs_2_public_ip
}