data opentelekomcloud_rds_flavors_v3 "flavours" {
  db_type       = "PostgreSQL"
  db_version    = var.psql_version
  instance_mode = "single"
}

resource "opentelekomcloud_rds_instance_v3" "instance" {
  availability_zone = [
    var.az
  ]
  db {
    password = var.psql_password
    type     = "PostgreSQL"
    version  = var.psql_version
    port     = var.psql_port
  }
  name              = var.instance_name
  security_group_id = opentelekomcloud_compute_secgroup_v2.db_local.id
  subnet_id         = var.subnet_id
  vpc_id            = var.network_id
  volume {
    type = "COMMON"
    size = 50
  }
  flavor = data.opentelekomcloud_rds_flavors_v3.flavours.flavors[1].name
  backup_strategy {
    start_time = "08:00-09:00"
    keep_days  = 1
  }
  depends_on = [
    opentelekomcloud_compute_secgroup_v2.db_local
  ]
}

output "db_username" {
  value = opentelekomcloud_rds_instance_v3.instance.db[0].user_name
}

output "db_password" {
  value     = opentelekomcloud_rds_instance_v3.instance.db[0].password
  sensitive = true
}

output "db_address" {
  value = "${opentelekomcloud_rds_instance_v3.instance.private_ips[0]}:${var.psql_port}"
}