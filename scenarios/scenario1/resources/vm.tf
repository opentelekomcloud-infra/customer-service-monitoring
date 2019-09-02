variable "ecs_local_ip_0" {}
variable "ecs_local_ip_1" {}

resource "opentelekomcloud_compute_keypair_v2" "pair_0" {
  name = "kp_0_${var.postfix}"
  public_key = var.public_key
}

resource "opentelekomcloud_compute_keypair_v2" "pair_1" {
  name = "kp_1_${var.postfix}"
  public_key = var.public_key
}

resource "opentelekomcloud_vpc_eip_v1" "scn1_eip_0" {

  bandwidth {
    name = "scn1_limit_0"
    share_type = "PER"
    size = 1
  }

  publicip {
    type = "5_bgp"
  }
}

resource "opentelekomcloud_vpc_eip_v1" "scn1_eip_1" {

  bandwidth {
    name = "scn1_limit_1"
    share_type = "PER"
    size = 1
  }

  publicip {
    type = "5_bgp"
  }
}

output "scn1_eip_0" {
  value = opentelekomcloud_vpc_eip_v1.scn1_eip_0.publicip[0].ip_address
}

output "scn1_eip_1" {
  value = opentelekomcloud_vpc_eip_v1.scn1_eip_1.publicip[0].ip_address
}

resource "opentelekomcloud_networking_port_v2" "port_0" {
  count              = 1
  name               = "port-http-0"
  network_id         = opentelekomcloud_networking_network_v2.generic.id
  admin_state_up     = true
  security_group_ids = opentelekomcloud_compute_secgroup_v2.http_https_ssh
  fixed_ip           = {
    subnet_id        = opentelekomcloud_networking_subnet_v2.subnet.id
  }
}

resource "opentelekomcloud_compute_instance_v2" "basic_0" {
  name = "${var.postfix}_server_0"
  image_name = var.centos_image
  flavor_id = var.default_flavor
  region = var.region
  availability_zone = "${var.region}-01"
  key_pair = opentelekomcloud_compute_keypair_v2.pair_0.name

  depends_on = [
    opentelekomcloud_networking_subnet_v2.subnet,
    opentelekomcloud_compute_keypair_v2.pair_0,
    opentelekomcloud_compute_secgroup_v2.http_https_ssh
  ]

  network {
    port = opentelekomcloud_networking_port_v2.port_0.id
  }
}

resource "opentelekomcloud_compute_floatingip_associate_v2" "assign_ip_0" {
  floating_ip = opentelekomcloud_vpc_eip_v1.scn1_eip_0.publicip[0].ip_address
  instance_id = opentelekomcloud_compute_instance_v2.basic_0.id
}

resource "opentelekomcloud_networking_port_v2" "port_1" {
  count              = 1
  name               = "port-http-1"
  network_id         = opentelekomcloud_networking_network_v2.generic.id
  admin_state_up     = true
  security_group_ids = opentelekomcloud_compute_secgroup_v2.http_https_ssh
  fixed_ip           = {
    subnet_id        = opentelekomcloud_networking_subnet_v2.subnet.id
  }
}

resource "opentelekomcloud_compute_instance_v2" "basic_1" {
  name = "${var.postfix}_server_1"
  image_name = var.centos_image
  flavor_id = var.default_flavor
  region = var.region
  availability_zone = "${var.region}-01"
  key_pair = opentelekomcloud_compute_keypair_v2.pair_1.name

  depends_on = [
    opentelekomcloud_networking_subnet_v2.subnet,
    opentelekomcloud_compute_keypair_v2.pair_1,
    opentelekomcloud_compute_secgroup_v2.http_https_ssh
  ]

  network {
    port = opentelekomcloud_networking_port_v2.port_1.id
  }
}

resource "opentelekomcloud_compute_floatingip_associate_v2" "assign_ip_1" {
  floating_ip = opentelekomcloud_vpc_eip_v1.scn1_eip_1.publicip[0].ip_address
  instance_id = opentelekomcloud_compute_instance_v2.basic_1.id
}
