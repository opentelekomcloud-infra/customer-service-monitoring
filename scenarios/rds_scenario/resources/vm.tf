resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name       = "${var.prefix}-kp"
  public_key = var.public_key
}

data "opentelekomcloud_images_image_v2" "current_image" {
  name        = var.ecs_image
  most_recent = true
}

resource "opentelekomcloud_compute_secgroup_v2" "rds_public" {
  description = "Allow external connections to ssh, http, and https ports"
  name        =  "${var.prefix}_grp"

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
  flavor_id  = var.ecs_flavor

  region            = var.region
  availability_zone = var.availability_zone
  key_pair          = opentelekomcloud_compute_keypair_v2.pair.name

  block_device {
    volume_size           = var.disc_volume
    destination_type      = "volume"
    delete_on_termination = true
    source_type           = "image"
    uuid                  = data.opentelekomcloud_images_image_v2.current_image.id
  }

  depends_on = [
    opentelekomcloud_networking_port_v2.network_port
  ]

  network {
    port = opentelekomcloud_networking_port_v2.network_port.id
  }

  tag = {
    "scenario" : var.prefix
  }
}

resource "opentelekomcloud_networking_port_v2" "network_port" {
  name           = "${var.prefix}_network_port"
  network_id     = var.network_id
  admin_state_up = true

  security_group_ids = [
    opentelekomcloud_compute_secgroup_v2.rds_public.id
  ]

  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = "${var.addr_3}.10"
  }
}

output "ip" {
  value = opentelekomcloud_compute_instance_v2.basic.access_ip_v4
}