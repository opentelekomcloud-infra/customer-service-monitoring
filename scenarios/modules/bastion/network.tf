# Network creation
resource "opentelekomcloud_networking_router_route_v2" "router_route_1" {
  router_id        = var.router.id
  destination_cidr = "0.0.0.0/24" // that's a hack
  next_hop         = opentelekomcloud_compute_instance_v2.bastion.access_ip_v4
}

# Acces group, open input port 80, 443 and ssh port

resource "opentelekomcloud_compute_secgroup_v2" "bastion_group" {
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

output "bastion_group_id" {
  value = opentelekomcloud_compute_secgroup_v2.bastion_group.id
}


# Create network port
resource "opentelekomcloud_networking_port_v2" "bastion_port" {
  name               = "${var.name}_port"
  network_id         = var.network.id
  admin_state_up     = true
  security_group_ids = [opentelekomcloud_compute_secgroup_v2.bastion_group.id]
  fixed_ip {
    subnet_id  = var.subnet.id
    ip_address = local.bastion_ip
  }
}

# Assign FIP to bastion
resource opentelekomcloud_compute_floatingip_associate_v2 "floatingip_associate_bastion" {
  floating_ip = var.bastion_eip
  instance_id = opentelekomcloud_compute_instance_v2.bastion.id
}
