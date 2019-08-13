variable "psql_port" {}
variable "psql_password" {}
variable "psql_version" {}
variable "psql_username" {}
variable "psql_flavor" {}

resource "opentelekomcloud_rds_instance_v3" "psql_db" {
  name = "PostgreSql server"
  availability_zone = [var.default_az]
  flavor = var.default_flavor
  security_group_id = opentelekomcloud_compute_secgroup_v2.local_only.id
  subnet_id = opentelekomcloud_vpc_subnet_v1.subnet.id
  vpc_id = opentelekomcloud_vpc_v1.vpc.id
  db {
    password = var.psql_password
    type = "PostgreSQL"
    version = var.psql_version
    port = var.psql_port
  }
  volume {
    size = 40
    type = "COMMON"
  }
}
