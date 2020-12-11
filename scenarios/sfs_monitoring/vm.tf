# Get info about image
data "opentelekomcloud_images_image_v2" "image" {
  name        = var.ecs_image
  most_recent = true
}

# Create security group for instances
resource "opentelekomcloud_compute_secgroup_v2" "sfs_monitoring_grp" {
  name        = "${var.scenario}_grp"
  description = "Allow external connections to ssh, http, and https ports"

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

# Create network port for iSCSI target
resource "opentelekomcloud_networking_port_v2" "target_instance_port" {
  name           = "${var.scenario}_target_port"
  network_id     = var.network.id
  admin_state_up = true

  security_group_ids = [
    opentelekomcloud_compute_secgroup_v2.sfs_monitoring_grp.id
  ]

  fixed_ip {
    subnet_id  = var.subnet.id
    ip_address = "${var.net_address}.10"
  }
}

# Create instance for iSCSI target
resource "opentelekomcloud_compute_instance_v2" "target_instance" {
  name        = "${var.scenario}_target_instance"
  flavor_name = var.ecs_flavor
  key_pair    = var.key_pair_name

  availability_zone = var.target_availability_zone

  network {
    port = opentelekomcloud_networking_port_v2.target_instance_port.id
  }

  block_device {
    volume_size           = var.disc_volume
    destination_type      = "volume"
    delete_on_termination = true
    source_type           = "image"
    uuid                  = data.opentelekomcloud_images_image_v2.image.id
  }

  tag = {
    group    = "gatewayed"
    scenario = var.scenario
  }
}

# Create network port for iSCSI initiator
resource "opentelekomcloud_networking_port_v2" "initiator_instance_port" {
  name           = "${var.scenario}_initiator_port"
  network_id     = var.network.id
  admin_state_up = true

  security_group_ids = [
    opentelekomcloud_compute_secgroup_v2.sfs_monitoring_grp.id
  ]

  fixed_ip {
    subnet_id  = var.subnet.id
    ip_address = "${var.net_address}.11"
  }
}

# Create instance for iSCSI initiator
resource "opentelekomcloud_compute_instance_v2" "initiator_instance" {
  name        = "${var.scenario}_initiator_instance"
  flavor_name = var.ecs_flavor
  key_pair    = var.key_pair_name

  availability_zone = var.initiator_availability_zone

  network {
    port = opentelekomcloud_networking_port_v2.initiator_instance_port.id
  }

  block_device {
    volume_size           = var.disc_volume
    destination_type      = "volume"
    delete_on_termination = true
    source_type           = "image"
    uuid                  = data.opentelekomcloud_images_image_v2.image.id
  }

  tag = {
    "group" : "gatewayed",
    "scenario" : var.scenario
  }
}


output "target_instance_ip" {
  value = opentelekomcloud_compute_instance_v2.target_instance.access_ip_v4
}

output "initiator_instance_ip" {
  value = opentelekomcloud_compute_instance_v2.initiator_instance.access_ip_v4
}
