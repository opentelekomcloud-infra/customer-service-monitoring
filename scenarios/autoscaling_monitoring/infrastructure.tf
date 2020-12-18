locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"

  key_pair = {
    public_key = var.public_key
    key_name = "${local.workspace_prefix}_kp_${var.scenario}"
  }
}

module "loadbalancer" {
  source = "../modules/loadbalancer"

  instances = module.resources.instances
  net_address = var.addr_3_octets
  subnet_id = var.subnet_id
  scenario = var.scenario
  workspace_prefix = local.workspace_prefix
}

module "resources" {
  source = "./resources"

  ecs_flavor = var.ecs_flavor
  availability_zone = var.availability_zone
  ecs_image = var.ecs_image
  nodes_count = var.nodes_count
  disc_volume = var.disc_volume
  key_pair = local.key_pair

  lb_monitor = module.loadbalancer.monitor
  lb_pool = module.loadbalancer.pool
  net_address = var.addr_3_octets
  subnet_id = var.subnet_id
  network_id = var.network_id
  router_id = var.router_id
  scenario = var.scenario
}

output "scn4_lb_fip" {
  value = module.loadbalancer.loadbalancer_fip
}

output "scn4_vms" {
  value = [for instance in module.resources.instances: instance.access_ip_v4]
}
