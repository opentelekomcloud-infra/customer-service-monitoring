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
  key_pair_name = local.key_pair.key_name
  nodes_count   = var.nodes_count
  scenario      = var.scenario

  network_id    = var.network_id
  subnet_id     = var.subnet_id
  node_local_ip = cidrhost(var.subnet_cidr, 10)
}

module "resources" {
  source = "./resources"

  ecs_image   = var.ecs_image
  ecs_flavor  = var.ecs_flavor
  key_pair    = local.key_pair
  subnet_cidr = var.subnet_cidr
  subnet_id   = var.subnet_id
  network_id  = var.network_id
  router_id   = var.router_id
  scenario    = var.scenario
}

module "loadbalancer" {
  source = "../modules/loadbalancer"

  instances        = module.nodes.instances
  scenario         = var.scenario
  subnet_id        = var.subnet_id
  workspace_prefix = local.workspace_prefix
  lb_local_ip      = cidrhost(local.scenario_subnet, 3)
}

output "lb_down_instance_fip" {
  value = module.loadbalancer.loadbalancer_fip
}

output "lb_down_ecs_ips" {
  value = [for instance in module.nodes.instances : instance.access_ip_v4]
}

output "lb_ctrl_ip" {
  value = module.resources.lb_fail_control_instance_ip
}
