locals {
  workspace_prefix = terraform.workspace == "default" ? "" : terraform.workspace
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}kp_${var.scenario}"
  }
}


module "nodes" {
  source = "../modules/ecs_node"

  ecs_flavor    = var.ecs_flavor
  ecs_image     = var.ecs_image
  key_pair      = local.key_pair
  nodes_count   = var.nodes_count
  scenario      = var.scenario

  net_address = var.addr_3_octets
  network_id  = var.network_id
  subnet_id   = var.subnet_id
}

module "loadbalancer" {
  source = "../modules/loadbalancer"

  instances        = module.nodes.instances
  net_address      = var.addr_3_octets
  scenario         = var.scenario
  subnet_id        = var.subnet_id
  workspace_prefix = local.workspace_prefix
}

output "lb_down_instance_fip" {
  value = module.loadbalancer.loadbalancer_fip
}

output "lb_down_ecs_ips" {
  value = [for instance in module.nodes.instances : instance.access_ip_v4]
}
