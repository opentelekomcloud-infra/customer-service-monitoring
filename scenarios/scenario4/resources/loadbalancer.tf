# Create loadbalancer
resource "opentelekomcloud_lb_loadbalancer_v2" "loadbalancer" {
  name          = "${local.workspace_prefix}${var.prefix}_elastic_loadbalancer_http"
  vip_subnet_id = var.subnet_id
  vip_address   = var.loadbalancer_local_ip
  depends_on = [
    opentelekomcloud_compute_instance_v2.http
  ]
}

resource "opentelekomcloud_networking_floatingip_v2" "loadbalancer_public_ip" {
  pool = "admin_external_net"
}

# Assign FIP to Loadbalancer
resource opentelekomcloud_networking_floatingip_associate_v2 "floatingip_associate_lb" {
  floating_ip = opentelekomcloud_networking_floatingip_v2.loadbalancer_public_ip.address
  port_id     = opentelekomcloud_lb_loadbalancer_v2.loadbalancer.vip_port_id
}

output "scn4_lb_fip" {
  value = opentelekomcloud_networking_floatingip_v2.loadbalancer_public_ip.address
}

# Create listener
resource "opentelekomcloud_lb_listener_v2" "listener" {
  name            = "${local.workspace_prefix}${var.prefix}_listener_http"
  protocol        = "TCP"
  protocol_port   = 80
  loadbalancer_id = opentelekomcloud_lb_loadbalancer_v2.loadbalancer.id
  depends_on = [
    opentelekomcloud_lb_loadbalancer_v2.loadbalancer
  ]
  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
}

# Set methode for load balance charge between instance
resource "opentelekomcloud_lb_pool_v2" "pool" {
  name        = "${local.workspace_prefix}${var.prefix}_pool_http"
  protocol    = "TCP"
  lb_method   = "ROUND_ROBIN"
  listener_id = opentelekomcloud_lb_listener_v2.listener.id
  depends_on = [
    opentelekomcloud_lb_listener_v2.listener
  ]
}

# Add multip instances to pool
resource "opentelekomcloud_lb_member_v2" "members" {
  count         = var.nodes_count
  address       = opentelekomcloud_compute_instance_v2.http.*.access_ip_v4[count.index]
  protocol_port = 80
  pool_id       = opentelekomcloud_lb_pool_v2.pool.id
  subnet_id     = var.subnet_id
  depends_on = [
    opentelekomcloud_lb_pool_v2.pool
  ]
}

# Create health monitor for check services instances status
resource "opentelekomcloud_lb_monitor_v2" "monitor" {
  name        = "${local.workspace_prefix}${var.prefix}_monitor_http"
  pool_id     = opentelekomcloud_lb_pool_v2.pool.id
  type        = "TCP"
  delay       = 1
  timeout     = 1
  max_retries = 2
  depends_on = [
    opentelekomcloud_lb_member_v2.members
  ]
}
