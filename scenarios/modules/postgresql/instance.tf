data opentelekomcloud_rds_flavors_v3 "flavours" {
  db_type       = "PostgreSQL"
  db_version    = var.psql_version
  instance_mode = "single"
}

resource "opentelekomcloud_rds_instance_v3" "instance" {
  availability_zone = [
    var.availability_zone
  ]
  db {
    password = var.psql_password
    type     = "PostgreSQL"
    version  = var.psql_version
    port     = var.psql_port
  }
  name              = var.instance_name
  security_group_id = opentelekomcloud_compute_secgroup_v2.db_local.id
  subnet_id         = "897ea15c-780c-4e8f-9a73-f4ac4533d5db"
  vpc_id            = var.router_id
  volume {
    type = "COMMON"
    size = 50
  }
  flavor = [
    for flavour in data.opentelekomcloud_rds_flavors_v3.flavours.flavors :
    flavour.name if flavour.memory > 4
  ][0]
  backup_strategy {
    start_time = "20:00-21:00"
    keep_days = 1
  }
  depends_on = [
    opentelekomcloud_compute_secgroup_v2.db_local
  ]
}

output "rds_instance_id"{
  value = opentelekomcloud_rds_instance_v3.instance.id
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

output "db_host" {
  value = opentelekomcloud_rds_instance_v3.instance.private_ips[0]
}

output "db_port" {
  value = var.psql_port
}
