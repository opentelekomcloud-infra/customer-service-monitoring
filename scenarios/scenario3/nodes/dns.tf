resource "opentelekomcloud_dns_zone_v2" "private_scenario5_com" {
  name  = "private.scenario5.com."
  email = "private@scenario5.com"
  description = "Private zone for csm scenario5"
  ttl  = 300
  type = "private"

  router {
     router_id     = var.network_id
     router_region = var.region
  }
}

resource "opentelekomcloud_dns_recordset_v2" "host_scenario5_com" {
  zone_id = opentelekomcloud_dns_zone_v2.private_scenario5_com.id
  name = "host.private.scenario5.com."
  description = "An record set for dns_host in csm scenario5"
  ttl = 300
  type = "A"
  records = [opentelekomcloud_networking_port_v2.dns_port.fixed_ip.ip_address]
}

output "dns_record" {
  value = opentelekomcloud_dns_recordset_v2.host_scenario5_com.name
}