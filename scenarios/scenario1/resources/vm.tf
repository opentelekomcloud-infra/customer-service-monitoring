variable "bastion_local_ip" {}
variable "nodes_count" {}
variable "key_pair_name" {}


# Create instance
resource "opentelekomcloud_compute_instance_v2" "http" {
  count       = var.nodes_count
  name        = "basic_${count.index}"
  image_name  = var.debian_image
  flavor_name = var.default_flavor
  key_pair    = var.key_pair_name
  user_data   = file("${path.module}/first_boot.sh")
  network {
    port = opentelekomcloud_networking_port_v2.http.*.id[count.index]
  }
}

# Create network port
resource "opentelekomcloud_networking_port_v2" "http" {
  count              = var.nodes_count
  name               = "port_${count.index}"
  network_id         = var.network_id
  admin_state_up     = true
  security_group_ids = [var.bastion_sec_group_id]
  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = "${var.net_address}.${count.index + 10}"
  }
}

