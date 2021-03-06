resource "opentelekomcloud_compute_keypair_v2" "kp" {
  name       = var.key_pair.key_name
  public_key = var.key_pair.public_key
}

data "opentelekomcloud_images_image_v2" "current_image" {
  name        = var.ecs_image
  most_recent = true
}

# Create security group for instances
resource "opentelekomcloud_compute_secgroup_v2" "hdd_group" {
  description = "Allow external connections to ssh port"
  name        = "${var.scenario}_grp"
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
  }
}

# Create instance
resource "opentelekomcloud_compute_instance_v2" "http" {
  count       = length(opentelekomcloud_networking_port_v2.http)
  name        = "${var.scenario}_${var.availability_zones[count.index]}_${local.workspace_prefix}"
  flavor_name = var.ecs_flavor
  key_pair    = opentelekomcloud_compute_keypair_v2.kp.name
  user_data   = file("${path.module}/first_boot.sh")

  availability_zone = var.availability_zones[count.index]

  depends_on = [
    opentelekomcloud_networking_port_v2.http
  ]

  network {
    port = opentelekomcloud_networking_port_v2.http[count.index].id
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

# Create network port
resource "opentelekomcloud_networking_port_v2" "http" {
  count          = var.nodes_count
  name           = "${var.scenario}_port_${count.index}_${local.workspace_prefix}"
  network_id     = var.network_id
  admin_state_up = true
  security_group_ids = [
    opentelekomcloud_compute_secgroup_v2.hdd_group.id
  ]
  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = cidrhost(var.subnet_cidr, count.index + 10)
  }
}

output "instances" {
  value = opentelekomcloud_compute_instance_v2.http
}
