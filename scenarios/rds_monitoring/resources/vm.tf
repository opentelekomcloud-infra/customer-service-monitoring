resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name       = var.key_pair.key_name
  public_key = var.key_pair.public_key
}

data "opentelekomcloud_images_image_v2" "current_image" {
  name        = var.ecs_image
  most_recent = true
}

resource "opentelekomcloud_compute_secgroup_v2" "rds_grp" {
  description = "Allow external connections to ssh, http, and https ports"
  name        = "${var.scenario}_grp"

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

resource "opentelekomcloud_compute_instance_v2" "ecs" {
  name      = "${var.scenario}_instance_${local.workspace_prefix}"
  flavor_id = var.ecs_flavor

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

  user_data = file("${path.module}/first_boot.sh")

  tag = {
    "group" : "gatewayed",
    "scenario" : var.scenario
  }
}


resource "opentelekomcloud_networking_port_v2" "network_port" {
  name           = "${var.scenario}_port_${local.workspace_prefix}"
  network_id     = var.network_id
  admin_state_up = true

  security_group_ids = [
    opentelekomcloud_compute_secgroup_v2.rds_grp.id
  ]

  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = "${var.addr_3}.10"
  }
}

output "ip" {
  value = opentelekomcloud_compute_instance_v2.ecs.access_ip_v4
}
