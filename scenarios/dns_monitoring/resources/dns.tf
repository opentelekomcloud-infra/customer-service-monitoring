# Create instance for DNS resolving
resource "opentelekomcloud_compute_instance_v2" "dns_host" {
  name        = var.scenario
  flavor_name = var.ecs_flavor
  key_pair    = var.key_pair_name

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
    uuid                  = data.opentelekomcloud_images_image_v2.current_image.id
  }

  tag = {
    "group" : "dns",
    "scenario" : var.scenario
  }
}

# Create network port for DNS resolving
resource "opentelekomcloud_networking_port_v2" "dns_port" {
  name           = var.port_dns_host
  network_id     = var.network_id
  admin_state_up = true
  security_group_ids = [
    var.bastion_sec_group_id
  ]
  fixed_ip {
    subnet_id  = var.subnet_id
    ip_address = "${var.net_address}.100"
  }
}

output "dns_instance_address" {
  value = opentelekomcloud_compute_instance_v2.dns_host.access_ip_v4
}

resource "opentelekomcloud_dns_zone_v2" "private_scn5_com" {
  name  = "private.dns-monitoring.com."
  email = "private@dns-monitoring.com"
  description = "Private zone for CSM DNS monitoring"
  ttl  = 300
  type = "private"

  router {
     router_id     = var.vpc_id
     router_region = var.region
  }
}

resource "opentelekomcloud_dns_recordset_v2" "host_dns_monitoring_com" {
  zone_id = opentelekomcloud_dns_zone_v2.private_scn5_com.id
  name = "host.private.dns-monitoring.com."
  description = "An record set for dns_host in CSM DNS monitoring"
  ttl = 300
  type = "A"
  records = [opentelekomcloud_compute_instance_v2.dns_host.access_ip_v4]
  depends_on = [
    opentelekomcloud_compute_instance_v2.dns_host
  ]
}

output "dns_record" {
  value = opentelekomcloud_dns_recordset_v2.host_dns_monitoring_com.name
}
