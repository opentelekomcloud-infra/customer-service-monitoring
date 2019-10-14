resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name       = "${var.postfix}_keypair"
  public_key = var.public_key
}

# Get the uuid of image
data "opentelekomcloud_images_image_v2" "current_deb_image" {
  name        = var.debian_image
  most_recent = true
}

resource "opentelekomcloud_compute_instance_v2" "bastion" {
  name        = "${var.postfix}_${var.name}"
  image_name  = var.debian_image
  flavor_name = var.default_flavor
  key_pair    = opentelekomcloud_compute_keypair_v2.pair.name
  user_data   = file("${path.module}/first_boot.sh")

  depends_on = [
    opentelekomcloud_networking_port_v2.server_port
  ]

  network {
    port = opentelekomcloud_networking_port_v2.server_port.id
  }
  # Install system in volume
  block_device {
    volume_size           = var.volume_server
    destination_type      = "volume"
    delete_on_termination = true
    source_type           = "image"
    uuid                  = data.opentelekomcloud_images_image_v2.current_deb_image.id
  }

  tag = { "group" : "scenario3" }
}

# Create volume
resource "opentelekomcloud_blockstorage_volume_v2" "volumes" {
  count = 3
  name = "${format("vol-%s", var.volume_type[count.index])}"
  size = 2
  volume_type = var.volume_type[count.index]

  depends_on = [
    opentelekomcloud_compute_instance_v2.bastion
  ]
}

# Attach volumes to instance
resource "opentelekomcloud_compute_volume_attach_v2" "attach-0" {
  instance_id = opentelekomcloud_compute_instance_v2.bastion.id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes[0].id
}

resource "opentelekomcloud_compute_volume_attach_v2" "attach-1" {
  instance_id = opentelekomcloud_compute_instance_v2.bastion.id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes[1].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach-0
  ]
}
resource "opentelekomcloud_compute_volume_attach_v2" "attach-2" {
  instance_id = opentelekomcloud_compute_instance_v2.bastion.id
  volume_id   = opentelekomcloud_blockstorage_volume_v2.volumes[2].id
  depends_on = [
    opentelekomcloud_compute_volume_attach_v2.attach-1
  ]
}

resource "opentelekomcloud_networking_floatingip_v2" "server_fip" {
  pool = "admin_external_net"
}

# Assign FIP to server
resource opentelekomcloud_compute_floatingip_associate_v2 "floatingip_associate_server" {
  floating_ip = opentelekomcloud_networking_floatingip_v2.server_fip.address
  instance_id = opentelekomcloud_compute_instance_v2.bastion.id
}

output "scn3_server_fip" {
  value = opentelekomcloud_compute_floatingip_associate_v2.floatingip_associate_server.floating_ip
}