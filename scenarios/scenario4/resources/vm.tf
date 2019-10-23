data "opentelekomcloud_images_image_v2" "current_image" {
  name        = var.debian_image
  most_recent = true
}

# Create instance
resource "opentelekomcloud_compute_instance_v2" "http" {
  count       = var.nodes_count
  name        = "${local.workspace_prefix}${var.prefix}_basic_${count.index}"
  flavor_name = var.default_flavor
  key_pair    = var.kp.key_name
  user_data   = file("${path.module}/first_boot.sh")

  availability_zone = var.az

  network {
    port = opentelekomcloud_networking_port_v2.http.*.id[count.index]
  }

  block_device {
    volume_size           = var.disc_volume
    destination_type      = "volume"
    delete_on_termination = true
    source_type           = "image"
    uuid                  = data.opentelekomcloud_images_image_v2.current_image.id
  }

  tag = { "group" : "gatewayed" }
}

# Create network port
resource "opentelekomcloud_networking_port_v2" "http" {
  count          = var.nodes_count
  name           = "${local.workspace_prefix}${var.prefix}_port_${count.index}"
  network_id     = var.network_id
  admin_state_up = true
  security_group_ids = [
  var.bastion_sec_group_id]
  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = "${var.net_address}.${count.index + 10}"
  }
}

