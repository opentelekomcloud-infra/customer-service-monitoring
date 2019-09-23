variable "bastion_local_ip" {}
variable "nodes_count" {}

resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name = "kp_${var.postfix}"
  public_key = var.public_key
}

# Create instance
resource "opentelekomcloud_compute_instance_v2" "http" {
  count              = var.nodes_count
  name               = "basic_${count.index}"
  image_name         = var.debian_image
  flavor_name        = var.default_flavor
  key_pair           = opentelekomcloud_compute_keypair_v2.pair.name
  user_data          = file("${path.cwd}/scripts/first_boot.sh")
  network {
    port             = opentelekomcloud_networking_port_v2.http.*.id[count.index]
  }
}

# Create network port
resource "opentelekomcloud_networking_port_v2" "http" {
  count              = var.nodes_count
  name               = "port_${count.index}"
  network_id         = opentelekomcloud_networking_network_v2.generic.id
  admin_state_up     = true
  security_group_ids = [opentelekomcloud_compute_secgroup_v2.http_https_ssh.id]
  fixed_ip {
    subnet_id = opentelekomcloud_networking_subnet_v2.subnet.id
    ip_address = "${var.net_address}.${count.index + 10}"
  }
}

# Create Bastion instance

# Get the uuid of image
data "opentelekomcloud_images_image_v2" "current_deb_image" {
  name        = var.debian_image
  most_recent = true
}

resource "opentelekomcloud_compute_instance_v2" "bastion" {
  name               = "bastion"
  image_name         = var.debian_image
  flavor_name        = var.default_flavor
  key_pair           = opentelekomcloud_compute_keypair_v2.pair.name
  user_data          = file("${path.cwd}/scripts/first_boot_bastion.sh")
  network {
    port             = opentelekomcloud_networking_port_v2.bastion_port.id
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

# Create network port
resource "opentelekomcloud_networking_port_v2" "bastion_port" {
  name               = "bastion_port"
  network_id         = opentelekomcloud_networking_network_v2.generic.id
  admin_state_up     = true
  security_group_ids = [opentelekomcloud_compute_secgroup_v2.http_https_ssh.id]
  fixed_ip {
    subnet_id = opentelekomcloud_networking_subnet_v2.subnet.id
    ip_address = var.bastion_local_ip
  }
}

# Assign FIP to bastion
resource opentelekomcloud_compute_floatingip_associate_v2 "floatingip_associate_bastion" {
  floating_ip = var.bastion_eip
  instance_id = opentelekomcloud_compute_instance_v2.bastion.id
}

output "scn1_bastion_fip" {
  value = var.bastion_eip
}
