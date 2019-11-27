locals {
  name_prefix = "image_making"
}
resource "opentelekomcloud_vpc_v1" "vpc" {
  cidr = "192.168.0.0/28"
  name = "image_vpc"
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet" {
  cidr       = "192.168.0.0/29"
  gateway_ip = "192.168.0.1"
  name       = "image_subnet"
  vpc_id     = opentelekomcloud_vpc_v1.vpc.id
  dns_list   = ["1.1.1.1", "8.8.8.8", "100.125.4.25", "100.125.129.199"]
}

resource "opentelekomcloud_compute_secgroup_v2" "group" {
  description = "Public group"
  name        = "public"
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
  }
}

data "opentelekomcloud_images_image_v2" "base_image" {
  name        = var.ecs_image
  most_recent = true
  visibility  = var.image_visibility
}

output "out-image_id" {
  value = data.opentelekomcloud_images_image_v2.base_image.id
}

output "out-group" {
  value = opentelekomcloud_compute_secgroup_v2.group.id
}

output "out-network_id" {
  value = opentelekomcloud_vpc_subnet_v1.subnet.id
}
