resource "opentelekomcloud_compute_secgroup_v2" "db_local" {
  description = "Sec group with only local access (rds)"
  name        = "local_only_rds"
  rule {
    from_port   = var.psql_port
    ip_protocol = "tcp"
    to_port     = var.psql_port
    cidr        = var.subnet_cidr
  }
}
