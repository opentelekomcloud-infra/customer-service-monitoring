variable "psql_port" {}
variable "psql_password" {}
variable "psql_version" {}
variable "psql_username" {}
variable "psql_flavor" {}

data "opentelekomcloud_identity_project_v3" "cur_project" {
  name = "eu-de_rus"
}

data opentelekomcloud_rds_flavors_v3 "flavours" {
  db_type = "PostgreSQL"
  db_version = var.psql_version
  instance_mode = "single"
}

resource "opentelekomcloud_rds_instance_v3" "instance" {
  availability_zone = [
    var.default_az
  ]
  db {
    password = var.psql_password
    type = "PostgreSQL"
    version = var.psql_version
    port = var.psql_port
  }
  name = "scn2-rds"
  security_group_id = opentelekomcloud_compute_secgroup_v2.local_only.id
  subnet_id = opentelekomcloud_vpc_subnet_v1.subnet.id
  vpc_id = opentelekomcloud_vpc_v1.vpc.id
  volume {
    type = "COMMON"
    size = 50
  }
  flavor = data.opentelekomcloud_rds_flavors_v3.flavours.flavors[1].name
  backup_strategy {
    start_time = "08:00-09:00"
    keep_days = 1
  }
  depends_on = [
    opentelekomcloud_compute_secgroup_v2.local_only
  ]
}
