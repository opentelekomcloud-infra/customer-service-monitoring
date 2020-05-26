module "resources" {
  source = "./resources"

  ecs_image   = var.ecs_image
  ecs_flavor  = var.ecs_flavor
  net_address = var.addr_3_octets
  prefix      = var.prefix
  public_key  = var.public_key

  region            = var.region
  availability_zone = var.availability_zone
  scenario          = var.scenario
}

module "postgresql" {
  source = "../modules/postgresql"

  availability_zone = var.availability_zone
  instance_name     = "scn6-db"

  network_id  = module.resources.vpc_id
  subnet_id   = module.resources.subnet.id
  subnet_cidr = module.resources.subnet.cidr

  psql_version  = var.psql_version
  psql_port     = var.psql_port
  psql_password = var.psql_password
}

output "scn_public_ip" {
  value = module.resources.scn_eip
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