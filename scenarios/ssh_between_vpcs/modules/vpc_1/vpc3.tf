resource "opentelekomcloud_vpc_v1" "vpc_1" {
  name = "${var.scenario}-vpc_1"
  cidr = "${var.vpc_1_cidr}.0/16"
}

resource "opentelekomcloud_vpc_subnet_v1" "subnet_1" {
  name   = "${var.scenario}-subnet_1"
  cidr   = "${var.vpc_1_cidr}.0/24"
  vpc_id = opentelekomcloud_vpc_v1.vpc_1.id
  gateway_ip    = "${var.vpc_1_cidr}.1"

  depends_on = [
    opentelekomcloud_vpc_v1.vpc_1
  ]
}


data "opentelekomcloud_images_image_v2" "ecs_image_1" {
  name        = var.ecs_image
  most_recent = true
}

resource "opentelekomcloud_compute_instance_v2" "ecs_1" {
  name            = "${var.scenario}-ecs_1"
  image_name  = var.ecs_image
  flavor_name = var.ecs_flavor
  availability_zone = var.availability_zone

  network {
    uuid = opentelekomcloud_vpc_subnet_v1.subnet_1.id
  }

  block_device {
    volume_size = var.volume_ecs
    destination_type = "volume"
    delete_on_termination = true
    source_type = "image"
    uuid = data.opentelekomcloud_images_image_v2.ecs_image_1.id
  }

  tag = {
    "scenario" : var.scenario
  }
}


output "vpc_1_id" {
  value = opentelekomcloud_vpc_v1.vpc_1.id
}

output "ecs_1_private_ip" {
  value = opentelekomcloud_compute_instance_v2.ecs_1.access_ip_v4
}