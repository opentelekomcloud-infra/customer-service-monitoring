locals {
  workspace_prefix = terraform.workspace == "default" ? "" : terraform.workspace
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}_kp_${var.scenario}"
  }
}


module "nodes" {
  source = "../modules/ecs_node"

  ecs_flavor    = var.ecs_flavor
  ecs_image     = var.ecs_image
  key_pair_name = local.key_pair.key_name
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

output "lb_fail_fip" {
  value = module.loadbalancer.loadbalancer_fip
}

output "lb_fail_ecs_ips" {
  value = [for instance in module.nodes.instances : instance.access_ip_v4]
}
