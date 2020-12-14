module "postgresql" {
  source = "../modules/postgresql"

  availability_zone = var.availability_zone
  instance_name     = "scn2-db"

  network_id  = module.resources.vpc_id
  subnet_id   = module.resources.subnet.id
  subnet_cidr = module.resources.subnet.cidr

  psql_version  = var.psql_version
  psql_port     = var.psql_port
  psql_password = var.psql_password
}

output "scn2_public_ip" {
  value = module.resources.scn2_eip
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
