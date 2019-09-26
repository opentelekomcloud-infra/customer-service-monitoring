# Network creation
resource "opentelekomcloud_networking_router_route_v2" "router_route_1" {
  router_id        = var.router.id
  destination_cidr = "0.0.0.0/24" // that's a hack
  next_hop         = opentelekomcloud_compute_instance_v2.bastion.access_ip_v4
}
