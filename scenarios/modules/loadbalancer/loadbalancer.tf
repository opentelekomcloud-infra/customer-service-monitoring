# Create loadbalancer
resource "opentelekomcloud_lb_loadbalancer_v2" "loadbalancer" {
  name          = "${var.workspace_prefix}${var.scenario}_elastic_loadbalancer_http"
  vip_subnet_id = var.subnet_id
  vip_address   = "${var.net_address}.3"
  depends_on = [
    var.instances
  ]
}

resource "opentelekomcloud_compute_floatingip_v2" "lb_public_ip" {}

# Assign FIP to Loadbalancer
resource "opentelekomcloud_networking_floatingip_associate_v2" "floatingip_associate_lb" {
  floating_ip = opentelekomcloud_compute_floatingip_v2.lb_public_ip.address
  port_id     = opentelekomcloud_lb_loadbalancer_v2.loadbalancer.vip_port_id
}

# Create listener
resource "opentelekomcloud_lb_listener_v2" "listener" {
  name            = "${var.workspace_prefix}${var.scenario}_listener_http"
  protocol        = var.protocol
  protocol_port   = var.protocol_port
  loadbalancer_id = opentelekomcloud_lb_loadbalancer_v2.loadbalancer.id
  depends_on = [
    opentelekomcloud_lb_loadbalancer_v2.loadbalancer
  ]
}

# Set methode for load balance charge between instance
resource "opentelekomcloud_lb_pool_v2" "pool" {
  name        = "${var.workspace_prefix}${var.scenario}_pool_http"
  protocol    = var.protocol
  lb_method   = var.pool_lb_method
  listener_id = opentelekomcloud_lb_listener_v2.listener.id
  depends_on = [
    opentelekomcloud_lb_listener_v2.listener
  ]
}

# Add multip instances to pool
resource "opentelekomcloud_lb_member_v2" "members" {
  count         = length(var.instances)
  address       = var.instances[count.index].access_ip_v4
  protocol_port = var.protocol_port
  pool_id       = opentelekomcloud_lb_pool_v2.pool.id
  subnet_id     = var.subnet_id
  depends_on = [
    opentelekomcloud_lb_pool_v2.pool
  ]
}

# Create health monitor for check services instances status
resource "opentelekomcloud_lb_monitor_v2" "monitor" {
  name        = "${var.workspace_prefix}${var.scenario}_monitor_http"
  pool_id     = opentelekomcloud_lb_pool_v2.pool.id
  type        = var.protocol
  delay       = var.monitor_delay
  timeout     = var.monitor_timeout
  max_retries = var.monitor_max_retries
  depends_on = [
    opentelekomcloud_lb_member_v2.members
  ]
}

output "loadbalancer_fip" {
  value = opentelekomcloud_compute_floatingip_v2.lb_public_ip.address
}

output "monitor" {
  value = opentelekomcloud_lb_monitor_v2.monitor
}

output "pool" {
  value = opentelekomcloud_lb_pool_v2.pool
}
