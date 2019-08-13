variable "ecs_local_ip" {}


resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name = "csn2_${var.postfix}"
  public_key = var.public_key
}

resource "opentelekomcloud_networking_floatingip_v2" "public_ip" {}


resource "opentelekomcloud_compute_instance_v2" "basic" {
  name = "${var.postfix}_server"
  image_name = var.centos_image
  flavor_id = var.default_flavor
  security_groups = [
    "default"
  ]

  region = var.region
  availability_zone = "${var.region}-01"
  key_pair = opentelekomcloud_compute_keypair_v2.pair.name

  depends_on = [
    opentelekomcloud_vpc_subnet_v1.subnet,
    opentelekomcloud_compute_keypair_v2.pair,
  ]

  network {
    uuid = opentelekomcloud_vpc_subnet_v1.subnet.id
    fixed_ip_v4 = var.ecs_local_ip
  }

}

resource "opentelekomcloud_compute_floatingip_associate_v2" "assign_ip" {
  floating_ip = opentelekomcloud_networking_floatingip_v2.public_ip.address
  instance_id = opentelekomcloud_compute_instance_v2.basic.id
}
