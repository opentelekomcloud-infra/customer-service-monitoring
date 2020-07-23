
locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  prefix           = "${local.workspace_prefix}${var.scenario}"
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

resource "opentelekomcloud_networking_floatingip_v2" "bastion_fip" {
  pool = "admin_external_net"
}

module "bastion" {
  source = "../modules/bastion"

  bastion_image     = var.ecs_image
  bastion_eip       = opentelekomcloud_networking_floatingip_v2.bastion_fip.address
  ecs_flavor        = var.ecs_flavor
  key_pair          = local.key_pair
  network           = module.network.network
  subnet            = module.network.subnet
  router            = module.network.router
  name              = "${local.workspace_prefix}bastion"
  availability_zone = var.availability_zone
  scenario          = var.scenario
}

module "nodes" {
  source               = "./nodes"
  ecs_flavor           = var.ecs_flavor
  ecs_image            = var.ecs_image
  key_pair_name        = local.key_pair.key_name
  net_address          = var.addr_3_octets
  network_id           = module.network.network.id
  subnet_id            = module.network.subnet.id
  vpc_id               = module.network.router.id
  bastion_sec_group_id = module.bastion.bastion_group_id
  scenario             = var.scenario
}

output "scn3_server_fip" {
  value = opentelekomcloud_networking_floatingip_v2.bastion_fip.address
}

output "scn3_ecs_local_ips" {
  value = [ for instance in module.nodes.instances: instance.access_ip_v4 ]
}

output "scn5_instance_address" {
  value = module.nodes.dns_instance_address
}

//output "scn5_dns_record_name" {
//  value = module.nodes.dns_record
//}
