resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name       = var.key_pair.key_name
  public_key = var.key_pair.public_key
}

# Create Bastion instance
# Get the uuid of image
data "opentelekomcloud_images_image_v2" "current_deb_image" {
  name        = var.bastion_image
  most_recent = true
}

resource "opentelekomcloud_compute_instance_v2" "bastion" {
  name        = "${var.scenario}_${var.name}"
  image_name  = var.bastion_image
  flavor_name = var.ecs_flavor
  key_pair    = opentelekomcloud_compute_keypair_v2.pair.name
  user_data = templatefile("${path.module}/first_boot_bastion.sh", {
    cidr            = var.subnet.cidr,
    bastion_address = local.bastion_local_ip,
  })

  availability_zone = var.availability_zone

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

  tag = {
    "scenario" : var.scenario
  }
}

output "bastion_ip" {
  value = local.bastion_local_ip
}
output "bastion_vm_id" {
  value = opentelekomcloud_compute_instance_v2.bastion.id
}
