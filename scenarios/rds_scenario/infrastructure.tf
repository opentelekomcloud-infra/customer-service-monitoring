module "postgresql" {
  source = "../modules/postgresql"

  availability_zone = var.availability_zone
  instance_name     = "scn2-db"

  network_id  = var.network_id
  router_id = var.router_id
  subnet_id   = var.subnet_id
  subnet_cidr = var.subnet_cidr

  psql_version  = var.psql_version
  psql_port     = var.psql_port
  psql_password = var.psql_password
}

output "scn2_public_ip" {
  value = var.controller_public_ip
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
