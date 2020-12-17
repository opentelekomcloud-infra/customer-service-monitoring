locals {
  workspace_prefix = terraform.workspace == "default" ? "" : terraform.workspace
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}_kp_${var.scenario}"
  }
}

module "nodes" {
  source               = "./resources"
  ecs_flavor           = var.ecs_flavor
  ecs_image            = var.ecs_image
  key_pair             = local.key_pair
  net_address          = var.addr_3
  network_id           = var.network_id
  subnet_id            = var.subnet_id
  vpc_id               = var.router_id
  scenario             = var.scenario
}

output "hdd_ecs_local_ips" {
  value = [ for instance in module.nodes.instances: instance.access_ip_v4 ]
}
