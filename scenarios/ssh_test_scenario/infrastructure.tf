locals {
  workspace_prefix = terraform.workspace == "default" ? "" : "${terraform.workspace}-"
  key_pair = {
    public_key = var.public_key
    key_name   = "${local.workspace_prefix}kp_${var.scenario}"
  }
}

resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name       = local.key_pair.key_name
  public_key = local.key_pair.public_key
}

data "opentelekomcloud_networking_network_v2" "network" {
  network_id = "dbfd038b-8896-43f5-923e-9ded3e70e0dd"
}

resource "opentelekomcloud_networking_subnet_v2" "subnet" {
  name            = "${var.scenario}-subnet"
  network_id      = data.opentelekomcloud_networking_network_v2.network.id
  cidr            = "${var.addr_3_octets}.0/24"
  dns_nameservers = ["100.125.4.25", "100.125.129.199"]
}

resource "opentelekomcloud_networking_router_interface_v2" "router_interface" {
  router_id = "4c137456-ba8b-4f17-95d8-b1e21dc6a9d2"
  subnet_id = opentelekomcloud_networking_subnet_v2.subnet.id
}

data "opentelekomcloud_images_image_v2" "ecs_image" {
  name        = var.ecs_image
  most_recent = true
}

resource "opentelekomcloud_networking_port_v2" "ecs_port" {
  name               = "${var.scenario}_port"
  network_id         = data.opentelekomcloud_networking_network_v2.network.id
  admin_state_up     = true
  fixed_ip {
    subnet_id  = opentelekomcloud_networking_subnet_v2.subnet.id
  }
}
resource "opentelekomcloud_compute_instance_v2" "server" {
  name        = "${var.scenario}-server"
  image_name  = var.ecs_image
  flavor_name = var.ecs_flavor

  availability_zone = var.availability_zone

  depends_on = [
    opentelekomcloud_networking_port_v2.ecs_port
  ]

  network {
    uuid = data.opentelekomcloud_networking_network_v2.network.id
  }
  # Install system in volume
  block_device {
    volume_size = var.volume_ecs
    destination_type = "volume"
    delete_on_termination = true
    source_type = "image"
    uuid = data.opentelekomcloud_images_image_v2.ecs_image.id
  }

  tag = {
    "scenario" : var.scenario
  }
}

output "ssh-check-server_ip" {
  value = opentelekomcloud_compute_instance_v2.server.access_ip_v4
}

