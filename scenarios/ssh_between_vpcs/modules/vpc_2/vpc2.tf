resource "opentelekomcloud_compute_keypair_v2" "vpc_2_pair" {
  name       = "${var.key_pair.key_name}-2"
  public_key = var.key_pair.public_key
}

resource "opentelekomcloud_vpc_v1" "vpc_2" {
  name = "${var.scenario}-vpc_2"
  cidr = "${var.vpc_2_cidr}.0/16"
}


resource "opentelekomcloud_vpc_subnet_v1" "subnet_2" {
  name   = "${var.scenario}-subnet_2"
  cidr   = "${var.vpc_2_cidr}.0/24"
  vpc_id = opentelekomcloud_vpc_v1.vpc_2.id
  gateway_ip    = "${var.vpc_2_cidr}.1"
  dns_list = ["100.125.4.25", "8.8.8.8"]
}

resource "opentelekomcloud_compute_secgroup_v2" "ecs_2_group" {
  description = "Allow external connections to ssh, http, and https ports"
  name        = "ecs_2_group"
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 80
    ip_protocol = "tcp"
    to_port     = 80
  }
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
  }
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 443
    ip_protocol = "tcp"
    to_port     = 443
  }
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = -1
    ip_protocol = "icmp"
    to_port     = -1
  }

}

data "opentelekomcloud_images_image_v2" "ecs_image_2" {
  name        = var.ecs_image
  most_recent = true
}

resource "opentelekomcloud_vpc_eip_v1" "vpc2_eip" {

  bandwidth {
    name       = "scn2_limit"
    share_type = "PER"
    size       = 10
  }

  publicip {
    type = "5_bgp"
  }
}

output "ecs_2_public_ip" {
  value = opentelekomcloud_vpc_eip_v1.vpc2_eip.publicip[0].ip_address
}

resource "opentelekomcloud_compute_floatingip_associate_v2" "assign_ip_vpc_2" {
  floating_ip = opentelekomcloud_vpc_eip_v1.vpc2_eip.publicip[0].ip_address
  instance_id = opentelekomcloud_compute_instance_v2.ecs_2.id
}


resource "opentelekomcloud_compute_instance_v2" "ecs_2" {
  name            = "${var.scenario}-ecs_2"
  image_name  = var.ecs_image
  flavor_name = var.ecs_flavor
  availability_zone = var.availability_zone
  security_groups = ["ecs_2_group"]
  key_pair    = opentelekomcloud_compute_keypair_v2.vpc_2_pair.name
  user_data   = file("${path.module}/first_boot.sh")

  network {
    uuid = opentelekomcloud_vpc_subnet_v1.subnet_2.id
  }

  block_device {
    volume_size = var.volume_ecs
    destination_type = "volume"
    delete_on_termination = true
    source_type = "image"
    uuid = data.opentelekomcloud_images_image_v2.ecs_image_2.id
  }

  tag = {
    "scenario" : var.scenario
  }
}

output "vpc_2_id" {
  value = opentelekomcloud_vpc_v1.vpc_2.id
}

output "ecs_2_private_ip" {
  value = opentelekomcloud_compute_instance_v2.ecs_2.access_ip_v4
}
