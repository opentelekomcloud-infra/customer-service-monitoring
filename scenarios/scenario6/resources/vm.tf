#Key pair for vm access
resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name       = "${var.prefix}_kp"
  public_key = var.public_key
}

#Elastic ip creation
resource "opentelekomcloud_vpc_eip_v1" "scn_eip" {

  bandwidth {
    name       = "scn6_limit"
    share_type = "PER"
    size       = 10
  }

  publicip {
    type = "5_bgp"
  }
}

#Security group creation
resource "opentelekomcloud_compute_secgroup_v2" "scn_public_secgroup" {
  description = "Allow external connections to ssh, http, and https ports"
  name        = "scn6_public_secgroup_rds"

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

#VM instance management creation
resource "opentelekomcloud_compute_instance_v2" "basic" {
  name       = "${var.prefix}-instance"
  image_name = var.ecs_image
  flavor_id  = var.ecs_flavor
  security_groups = [
    opentelekomcloud_compute_secgroup_v2.scn_public_secgroup.id
  ]

  region            = var.region
  availability_zone = var.availability_zone
  key_pair          = opentelekomcloud_compute_keypair_v2.pair.name

  depends_on = [
    opentelekomcloud_vpc_subnet_v1.subnet,
    opentelekomcloud_compute_keypair_v2.pair,
    opentelekomcloud_compute_secgroup_v2.scn_public_secgroup
  ]

  network {
    uuid        = opentelekomcloud_vpc_subnet_v1.subnet.id
    fixed_ip_v4 = "${var.net_address}.10"
  }

  tag = {
    "scenario" : var.scenario
  }
}

#assigning ip
resource "opentelekomcloud_compute_floatingip_associate_v2" "assign_ip" {
  floating_ip = opentelekomcloud_vpc_eip_v1.scn_eip.publicip[0].ip_address
  instance_id = opentelekomcloud_compute_instance_v2.basic.id
}

#output value of elastic ip
output "scn_eip" {
  value = opentelekomcloud_vpc_eip_v1.scn_eip.publicip[0].ip_address
}

