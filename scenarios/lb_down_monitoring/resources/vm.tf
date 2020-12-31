locals {
  workspace_prefix = terraform.workspace == "default" ? "" : terraform.workspace
}

resource "opentelekomcloud_compute_keypair_v2" "kp" {
  name       = var.key_pair.key_name
  public_key = var.key_pair.public_key
}

data "opentelekomcloud_images_image_v2" "current_image" {
  name        = var.ecs_image
  most_recent = true
}

# Create security group for instances
resource "opentelekomcloud_compute_secgroup_v2" "lb_group" {
  description = "Allow external connections to ssh and http ports"
  name        = "${var.scenario}_grp"
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
  }
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 80
    ip_protocol = "tcp"
    to_port     = 80
  }
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 8080
    ip_protocol = "tcp"
    to_port     = 8080
  }
}

# Create control instance for lb
resource "opentelekomcloud_compute_instance_v2" "lb_control_instance_ip" {
  name        = "${var.scenario}_control_instance_${local.workspace_prefix}"
  flavor_name = var.ecs_flavor
  key_pair    = opentelekomcloud_compute_keypair_v2.kp.name
  user_data   = file("${path.module}/first_boot.sh")

  availability_zone = var.availability_zone

  network {
    port = opentelekomcloud_networking_port_v2.lb_instance_port.id
  }

  block_device {
    volume_size           = var.disc_volume
    destination_type      = "volume"
    delete_on_termination = true
    source_type           = "image"
    uuid                  = data.opentelekomcloud_images_image_v2.current_image.id
  }

  tag = {
    "group" : "gatewayed",
    "scenario" : var.scenario
  }
}

# Create network port for lb instance
resource "opentelekomcloud_networking_port_v2" "lb_instance_port" {
  name           = "${var.scenario}_lb_port"
  network_id     = var.network_id
  admin_state_up = true

  security_group_ids = [
    opentelekomcloud_compute_secgroup_v2.lb_group.id
  ]

  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = cidrhost(var.subnet_cidr, 1)
  }
}

output "lb_fail_control_instance_ip" {
  value = opentelekomcloud_compute_instance_v2.lb_control_instance_ip.access_ip_v4
}
