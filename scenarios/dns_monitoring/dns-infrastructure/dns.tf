resource "opentelekomcloud_compute_keypair_v2" "dns-kp" {
  name       = var.key_pair.key_name
  public_key = var.key_pair.public_key
}

data "opentelekomcloud_images_image_v2" "dns_monitoring_image" {
  name        = var.ecs_image
  most_recent = true
}

# Create security group for instance
resource "opentelekomcloud_compute_secgroup_v2" "dns_group" {
  description = "Allow external connections to ssh"
  name        = "${var.scenario}_grp"
  rule {
    cidr        = "0.0.0.0/0"
    from_port   = 22
    ip_protocol = "tcp"
    to_port     = 22
  }
}

# Create instance for DNS resolving
resource "opentelekomcloud_compute_instance_v2" "dns_instance" {
  name        = "${var.scenario}_instance"
  flavor_name = var.ecs_flavor
  key_pair    = opentelekomcloud_compute_keypair_v2.dns-kp.name

  availability_zone = var.availability_zone

  depends_on = [
    opentelekomcloud_networking_port_v2.dns_port
  ]

  network {
    port = opentelekomcloud_networking_port_v2.dns_port.id
  }

  block_device {
    volume_size           = var.disc_volume
    destination_type      = "volume"
    delete_on_termination = true
    source_type           = "image"
    uuid                  = data.opentelekomcloud_images_image_v2.dns_monitoring_image.id
  }

  tag = {
    "group" : "dns",
    "scenario" : var.scenario
  }
}

# Create network port for DNS resolving
resource "opentelekomcloud_networking_port_v2" "dns_port" {
  name           = var.scenario
  network_id     = var.network_id
  admin_state_up = true
  security_group_ids = [
    opentelekomcloud_compute_secgroup_v2.dns_group.id
  ]
  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = "${var.net_address}.100"
  }
}

resource "opentelekomcloud_dns_zone_v2" "private_dns_monitoring_com" {
  name        = "private.dns-monitoring.com."
  email       = "private@dns-monitoring.com"
  description = "Private zone for CSM DNS monitoring"
  ttl         = 300
  type        = "private"

  router {
    router_id     = var.router_id
    router_region = var.region
  }
}

resource "opentelekomcloud_dns_recordset_v2" "host_dns_monitoring_com" {
  zone_id     = opentelekomcloud_dns_zone_v2.private_dns_monitoring_com.id
  name        = "host.private.dns-monitoring.com."
  description = "An record set for dns_host in CSM DNS monitoring"
  ttl         = 300
  type        = "A"
  records = [
    opentelekomcloud_compute_instance_v2.dns_instance.access_ip_v4
  ]
  depends_on = [
    opentelekomcloud_compute_instance_v2.dns_instance
  ]
}

output "dns_record" {
  value = opentelekomcloud_dns_recordset_v2.host_dns_monitoring_com.name
}

output "dns_instance" {
  value = opentelekomcloud_compute_instance_v2.dns_instance.access_ip_v4
}
