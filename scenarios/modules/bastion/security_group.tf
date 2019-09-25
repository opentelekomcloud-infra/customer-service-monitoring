# Acces group, open input port 80, 443 and ssh port
resource "opentelekomcloud_compute_secgroup_v2" "basion_group" {
  description = "Allow external connections to ssh, http, and https ports"
  name        = "${var.name}_grp"
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 80
    ip_protocol = "tcp"
    to_port     = 80
  }
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
  }
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 443
    ip_protocol = "tcp"
    to_port     = 443
  }
}

output "basion_group_id" {
  value = opentelekomcloud_compute_secgroup_v2.basion_group.id
}

