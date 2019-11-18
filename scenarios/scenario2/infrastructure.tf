module "resources" {
  source = "./resources"

  centos_image   = var.vm_image
  default_flavor = var.default_flavor
  net_address    = var.net_address
  postfix        = var.postfix
  public_key     = var.public_key
  region         = var.region
}

module "postgresql" {
  source = "../modules/postgresql"

  az            = var.default_az
  instance_name = "scn2-db"
  network_id    = module.resources.vpc_id
  psql_password = var.psql_password
  psql_port     = var.psql_port
  subnet_cidr   = module.resources.subnet.cidr
  subnet_id     = module.resources.subnet.id
  psql_version  = var.psql_version
}

output "out-scn2_public_ip" {
  value = module.resources.scn2_eip
}
output "out-db_password" {
  value     = module.postgresql.db_password
  sensitive = true
}
output "out-db_username" {
  value = module.postgresql.db_username
}
output "out-db_address" {
  value = module.postgresql.db_address
}

