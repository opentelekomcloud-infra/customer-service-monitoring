# Create loadbalancer
resource "opentelekomcloud_lb_loadbalancer_v2" "loadbalancer" {
  name          = "${local.workspace_prefix}elastic_loadbalancer_http"
  vip_subnet_id = var.subnet_id
  vip_address   = var.loadbalancer_local_ip
  depends_on = [
    opentelekomcloud_compute_instance_v2.http
  ]
}

resource "opentelekomcloud_compute_floatingip_v2" "lb_public_ip" {}

# Assign FIP to Loadbalancer
resource opentelekomcloud_networking_floatingip_associate_v2 "floatingip_associate_lb" {
  floating_ip = opentelekomcloud_compute_floatingip_v2.lb_public_ip.address
  port_id     = opentelekomcloud_lb_loadbalancer_v2.loadbalancer.vip_port_id
}

output "scn1_lb_fip" {
  value = opentelekomcloud_compute_floatingip_v2.lb_public_ip.address
}

# Create listener
resource "opentelekomcloud_lb_listener_v2" "listener" {
  name            = "${local.workspace_prefix}listener_http"
  protocol        = "TCP"
  protocol_port   = 80
  loadbalancer_id = opentelekomcloud_lb_loadbalancer_v2.loadbalancer.id
  depends_on = [
    opentelekomcloud_lb_loadbalancer_v2.loadbalancer
  ]
}

# Set methode for load balance charge between instance
resource "opentelekomcloud_lb_pool_v2" "pool" {
  name        = "${local.workspace_prefix}pool_http"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = opentelekomcloud_lb_listener_v2.listener.id
  depends_on = [
    opentelekomcloud_lb_listener_v2.listener
  ]
}

# Add multip instances to pool
resource "opentelekomcloud_lb_member_v2" "members" {
  count         = length(opentelekomcloud_compute_instance_v2.http)
  address       = opentelekomcloud_compute_instance_v2.http[count.index].access_ip_v4
  protocol_port = 80
  pool_id       = opentelekomcloud_lb_pool_v2.pool.id
  subnet_id     = var.subnet_id
  depends_on = [
    opentelekomcloud_lb_pool_v2.pool
  ]
}

# Create health monitor for check services instances status
resource "opentelekomcloud_lb_monitor_v2" "monitor" {
  name        = "${local.workspace_prefix}monitor_http"
  pool_id     = opentelekomcloud_lb_pool_v2.pool.id
  type        = "TCP"
  delay       = 1
  timeout     = 1
  max_retries = 2
  depends_on = [
    opentelekomcloud_lb_member_v2.members
  ]
}
