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

resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name       = "${var.prefix}-kp"
  public_key = var.public_key
}

resource "opentelekomcloud_compute_secgroup_v2" "rds_public" {
  description = "Allow external connections to ssh, http, and https ports"
  name        = "scn2_public"

  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 80
    ip_protocol = "tcp"
    to_port     = 80
  }
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 443
    ip_protocol = "tcp"
    to_port     = 443
  }
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
  }
}

resource "opentelekomcloud_compute_instance_v2" "basic" {
  name       = "${var.prefix}-instance"
  image_name = var.ecs_image
  flavor_id  = var.ecs_flavor
  security_groups = [
    opentelekomcloud_compute_secgroup_v2.rds_public.id
  ]

  region            = var.region
  availability_zone = var.availability_zone
  key_pair          = opentelekomcloud_compute_keypair_v2.pair.name

  depends_on = [
    opentelekomcloud_compute_keypair_v2.pair,
    opentelekomcloud_compute_secgroup_v2.rds_public
  ]

  network {
    uuid        = var.subnet_id
  }

  tag = {
    "scenario" : var.scenario
  }
}

output "ecs_ip" {
  value     = opentelekomcloud_compute_instance_v2.basic.access_ip_v4
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
