resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name       = var.key_pair.key_name
  public_key = var.key_pair.public_key
}

# Create Bastion instance
# Get the uuid of image
data "opentelekomcloud_images_image_v2" "current_deb_image" {
  name        = var.debian_image
  most_recent = true
}


locals {
  // replace last subnet address octet with 2, e.g. 192.168.0.2 for 192.168.0.0
  bastion_ip_default = "${regex("^((?:\\d{1,3}\\.){3})(\\d)(?:/\\d+$)", var.subnet.cidr)[0]}2"
  bastion_ip         = var.bastion_local_ip != "" ? var.bastion_local_ip : local.bastion_ip_default
}

resource "opentelekomcloud_compute_instance_v2" "bastion" {
  name        = var.name
  image_name  = var.debian_image
  flavor_name = var.default_flavor
  key_pair    = opentelekomcloud_compute_keypair_v2.pair.name
  user_data = templatefile("${path.module}/first_boot_bastion.sh", {
    cidr            = var.subnet.cidr,
    bastion_address = local.bastion_ip,
  })

  depends_on = [
    opentelekomcloud_networking_port_v2.bastion_port
  ]

  network {
    port = opentelekomcloud_networking_port_v2.bastion_port.id
  }
  # Install system in volume
  block_device {
    volume_size           = var.volume_bastion
    destination_type      = "volume"
    delete_on_termination = true
    source_type           = "image"
    uuid                  = data.opentelekomcloud_images_image_v2.current_deb_image.id
  }
}


output "bastion_ip" {
  value = local.bastion_ip
}
