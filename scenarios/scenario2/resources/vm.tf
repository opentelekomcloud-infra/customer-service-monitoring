resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name       = "csn2_${var.postfix}"
  public_key = var.public_key
}

resource "opentelekomcloud_vpc_eip_v1" "scn2_eip" {

  bandwidth {
    name       = "scn2_limit"
    share_type = "PER"
    size       = 10
  }

  publicip {
    type = "5_bgp"
  }
}

output "scn2_eip" {
  value = opentelekomcloud_vpc_eip_v1.scn2_eip.publicip[0].ip_address
}

resource "opentelekomcloud_compute_secgroup_v2" "scn2_public" {
  description = "Allow external connections to ssh, http, and https ports"
  name        = "scn2_public"

  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 80
    ip_protocol = "tcp"
    to_port     = 80
  }
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 443
    ip_protocol = "tcp"
    to_port     = 443
  }
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
  }
}

resource "opentelekomcloud_compute_instance_v2" "basic" {
  name       = "${var.postfix}_server"
  image_name = var.centos_image
  flavor_id  = var.default_flavor
  security_groups = [
    opentelekomcloud_compute_secgroup_v2.scn2_public.id
  ]

  region            = var.region
  availability_zone = "${var.region}-01"
  key_pair          = opentelekomcloud_compute_keypair_v2.pair.name

  depends_on = [
    opentelekomcloud_vpc_subnet_v1.subnet,
    opentelekomcloud_compute_keypair_v2.pair,
    opentelekomcloud_compute_secgroup_v2.scn2_public
  ]

  network {
    uuid        = opentelekomcloud_vpc_subnet_v1.subnet.id
    fixed_ip_v4 = "${var.net_address}.10"
  }

}

resource "opentelekomcloud_compute_floatingip_associate_v2" "assign_ip" {
  floating_ip = opentelekomcloud_vpc_eip_v1.scn2_eip.publicip[0].ip_address
  instance_id = opentelekomcloud_compute_instance_v2.basic.id
}
