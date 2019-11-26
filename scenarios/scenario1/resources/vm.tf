data "opentelekomcloud_images_image_v2" "current_image" {
  name        = var.ecs_image
  most_recent = true
}

# Create instance
resource "opentelekomcloud_compute_instance_v2" "http" {
  count       = length(opentelekomcloud_networking_port_v2.http)
  name        = "${local.workspace_prefix}basic_${count.index}"
  flavor_name = var.ecs_flavor
  key_pair    = var.key_pair_name
  user_data   = file("${path.module}/first_boot.sh")

  availability_zone = "eu-de-03"

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

  tag = { "group" : "gatewayed", "scenario": var.postfix }
}

# Create network port
resource "opentelekomcloud_networking_port_v2" "http" {
  count          = var.nodes_count
  name           = "${local.workspace_prefix}port_${count.index}"
  network_id     = var.network_id
  admin_state_up = true
  security_group_ids = [
    var.bastion_sec_group_id
  ]
  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = "${var.net_address}.${count.index + 10}"
  }
}

output "ports" {
  value = opentelekomcloud_networking_port_v2.http
}

