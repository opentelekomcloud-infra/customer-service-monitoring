resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name       = var.key_pair.key_name
  public_key = var.key_pair.public_key
}

data "opentelekomcloud_images_image_v2" "current_image" {
  name        = var.ecs_image
  most_recent = true
}

# Create security group for instances
resource "opentelekomcloud_compute_secgroup_v2" "scn3_5_group" {
  description = "Allow external connections to ssh, http, and https ports"
  name        = "${var.prefix}_grp"
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
  }
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 3260
    ip_protocol = "tcp"
    to_port     = 3260
  }
}

# Create instance for iscsi target
resource "opentelekomcloud_compute_instance_v2" "target_instance" {
  name        = "${var.prefix}_target_instance"
  flavor_name = var.ecs_flavor
  key_pair    = opentelekomcloud_compute_keypair_v2.pair.name

  availability_zone = var.target_availability_zone

  network {
    port = opentelekomcloud_networking_port_v2.target_instance_port.id
  }

  block_device {
    volume_size           = var.disc_volume
    destination_type      = "volume"
    delete_on_termination = true
    source_type           = "image"
    uuid                  = data.opentelekomcloud_images_image_v2.current_image.id
  }

}

# Create network port for iscsi target
resource "opentelekomcloud_networking_port_v2" "target_instance_port" {
  name           = "${var.prefix}_target_port"
  network_id     = var.network.id
  admin_state_up = true

  security_group_ids = [
    opentelekomcloud_compute_secgroup_v2.scn3_5_group.id
  ]

  fixed_ip {
    subnet_id  = var.subnet.id
    ip_address = "${var.net_address}.10"
  }
}

resource "opentelekomcloud_networking_floatingip_v2" "target_fip" {
  pool = "admin_external_net"
}

# Assign FIP to target instance
resource opentelekomcloud_compute_floatingip_associate_v2 "floatingip_associate_target" {
  floating_ip = opentelekomcloud_networking_floatingip_v2.target_fip.address
  instance_id = opentelekomcloud_compute_instance_v2.target_instance.id
}

# Create instance for iscsi initiator
resource "opentelekomcloud_compute_instance_v2" "initiator_instance" {
  name        = "${var.prefix}_initiator_instance"
  flavor_name = var.ecs_flavor
  key_pair    = opentelekomcloud_compute_keypair_v2.pair.name

  availability_zone = var.initiator_availability_zone

  network {
    port = opentelekomcloud_networking_port_v2.initiator_instance_port.id
  }

  block_device {
    volume_size           = var.disc_volume
    destination_type      = "volume"
    delete_on_termination = true
    source_type           = "image"
    uuid                  = data.opentelekomcloud_images_image_v2.current_image.id
  }

}

# Create network port for iscsi initiator
resource "opentelekomcloud_networking_port_v2" "initiator_instance_port" {
  name           = "${var.prefix}_initiator_port"
  network_id     = var.network.id
  admin_state_up = true

  security_group_ids = [
    opentelekomcloud_compute_secgroup_v2.scn3_5_group.id
  ]

  fixed_ip {
    subnet_id  = var.subnet.id
    ip_address = "${var.net_address}.11"
  }
}

resource "opentelekomcloud_networking_floatingip_v2" "initiator_fip" {
  pool = "admin_external_net"
}

# Assign FIP to target initiator
resource opentelekomcloud_compute_floatingip_associate_v2 "floatingip_associate_initiator" {
  floating_ip = opentelekomcloud_networking_floatingip_v2.initiator_fip.address
  instance_id = opentelekomcloud_compute_instance_v2.initiator_instance.id
}

output "target_fip" {
  value = opentelekomcloud_networking_floatingip_v2.target_fip.address
}
output "initiator_fip" {
  value = opentelekomcloud_networking_floatingip_v2.initiator_fip.address
}