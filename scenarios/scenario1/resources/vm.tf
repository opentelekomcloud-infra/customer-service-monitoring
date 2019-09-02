variable "ecs_local_ips" {}

resource "opentelekomcloud_compute_keypair_v2" "pair" {
  name = "kp_${var.postfix}"
  public_key = var.public_key
}

# Create instance
#
resource "opentelekomcloud_compute_instance_v2" "http" {
  count              = 2
  name               = "basic_${count.index}"
  image_name         = var.centos_image
  flavor_name        = var.default_flavor
  key_pair           = opentelekomcloud_compute_keypair_v2.pair.name
  network {
    port             = opentelekomcloud_networking_port_v2.http.*.id[count.index]
  }
}

# Create network port
resource "opentelekomcloud_networking_port_v2" "http" {
  count              = 2
  name               = "port_${count.index}"
  network_id         = opentelekomcloud_networking_network_v2.generic.id
  admin_state_up     = true
  security_group_ids = [opentelekomcloud_compute_secgroup_v2.http_https_ssh.id]
  fixed_ip {
    subnet_id = opentelekomcloud_networking_subnet_v2.subnet.id
    ip_address = var.ecs_local_ips[count.index]
  }
}
