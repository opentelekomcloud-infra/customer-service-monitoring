locals {
  name_prefix = "image_making"
}
resource "opentelekomcloud_networking_network_v2" "network" {
}

resource "opentelekomcloud_networking_subnet_v2" "subnet" {
  cidr = "192.168.0.0/29"
  network_id = opentelekomcloud_networking_network_v2.network.id
}

resource "opentelekomcloud_compute_secgroup_v2" "group" {
  description = "Public group"
  name = "ssh_allowed"
  rule {
    cidr        = "129.168.0.0/29"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
  }
}

data "opentelekomcloud_images_image_v2" "base_image" {
  name = "Standard_Debian_10_latest"
  most_recent = true
  visibility = "public"
}

output "out-image_id" {
  value = data.opentelekomcloud_images_image_v2.base_image.id
}

output "out-group" {
  value = opentelekomcloud_compute_secgroup_v2.group.id
}

output "out-network_id" {
  value = opentelekomcloud_networking_subnet_v2.subnet.network_id
}

