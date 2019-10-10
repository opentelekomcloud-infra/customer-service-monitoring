# Acces group, open input port 80, 443 and ssh port

resource "opentelekomcloud_compute_secgroup_v2" "server_group" {
  description = "Allow external connections to ssh, http, and https ports"
  name        = "${var.postfix}_grp"
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


# Create network port
resource "opentelekomcloud_networking_port_v2" "server_port" {
  name               = "${var.postfix}_port"
  network_id         = var.network.id
  admin_state_up     = true
  security_group_ids = [opentelekomcloud_compute_secgroup_v2.server_group.id]
  fixed_ip {
    subnet_id  = var.subnet.id
    ip_address = var.net_address
  }
}
