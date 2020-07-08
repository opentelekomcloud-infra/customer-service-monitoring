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
  records = [opentelekomcloud_compute_instance_v2.dns.access_ip_v4]
  depends_on = [
    opentelekomcloud_compute_instance_v2.dns
  ]
}

output "dns_record" {
  value = opentelekomcloud_dns_recordset_v2.host_scenario5_com.name
}