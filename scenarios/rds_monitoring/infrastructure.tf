module "postgresql" {
  source = "../modules/postgresql"

  availability_zone = var.availability_zone
  instance_name     = "${var.prefix}_db"

  network_id  = var.network_id
  router_id = var.router_id
  subnet_id   = var.subnet_id
  subnet_cidr = "${var.addr_3}.0/24"

  psql_version  = var.psql_version
  psql_port     = var.psql_port
  psql_password = var.psql_password
}

module "resources" {
  source = "./resources"

  availability_zone = var.availability_zone
  public_key     = var.public_key
  ecs_image      = var.ecs_image
  ecs_flavor     = var.ecs_flavor
  scenario       = var.scenario
  region         = var.region

  addr_3    = var.addr_3
  subnet_id      = var.subnet_id
  network_id     = var.network_id
  router_id      = var.router_id
}

output "ecs_ip" {
  value     = module.resources.ip
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
