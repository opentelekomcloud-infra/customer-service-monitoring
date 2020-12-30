locals {
  workspace_prefix = terraform.workspace == "default" ? "" : terraform.workspace
  key_pair         = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}_kp_${var.scenario}"
  }
}

module "postgresql" {
  source = "../modules/postgresql"

  availability_zone = var.availability_zone
  instance_name     = "${var.scenario}_db_${local.workspace_prefix}"

  network_id    = var.network_id
  router_id     = var.router_id
  subnet_id     = var.network_id
  subnet_cidr   = local.scenario_subnet
  psql_version  = var.psql_version
  psql_port     = var.psql_port
  psql_password = var.psql_password
}

module "resources" {
  source = "./resources"

  availability_zone = var.availability_zone
  key_pair          = local.key_pair
  ecs_image         = var.ecs_image
  ecs_flavor        = var.ecs_flavor
  scenario          = var.scenario
  region            = var.region
  subnet_cidr       = local.scenario_subnet
  subnet_id         = var.subnet_id
  network_id        = var.network_id
  router_id         = var.router_id
}

output "ecs_ip" {
  value = module.resources.ip
}

output "db_password" {
  value     = module.postgresql.db_password
  sensitive = true
}
output "db_username" {
  value = module.postgresql.db_username
}
output "db_address" {
  value = module.postgresql.db_address
}
