# HTTP LOAD BALANCER CONFIGURATION
#
# Create loadbalancer
resource "openstack_lb_loadbalancer_v2" "loadbalancer" {
  name            = "elastic_loadbalancer_http"
  vip_subnet_id   = "${opentelekomcloud_vpc_subnet_v1.subnet.vpc_id}"
  depends_on      = [
    "opentelekomcloud_compute_instance_v2.basic_0",
    "opentelekomcloud_compute_instance_v2.basic_1"
  ]
}

# Create listener
resource "openstack_lb_listener_v2" "listener" {
  name            = "listener_http"
  protocol        = "TCP"
  protocol_port   = 80
  loadbalancer_id = "${openstack_lb_loadbalancer_v2.loadbalancer.id}"
  depends_on      = [
      "openstack_lb_loadbalancer_v2.loadbalancer"
    ]
}

# Set methode for load balance charge between instance
resource "openstack_lb_pool_v2" "pool" {
  name            = "pool_http"
  protocol        = "TCP"
  lb_method       = "ROUND_ROBIN"
  listener_id     = "${openstack_lb_listener_v2.listener.id}"
  depends_on      = [
      "openstack_lb_listener_v2.listener"
    ]
}

# Add multip instances to pool
resource "openstack_lb_member_v2" "members" {
  count           = 2
  address         = ["${var.ecs_local_ip_0}", "${var.ecs_local_ip_1}"]
  protocol_port   = 80
  pool_id         = "${openstack_lb_pool_v2.pool.id}"
  subnet_id       = "${opentelekomcloud_vpc_subnet_v1.subnet.vpc_id}"
  depends_on      = [
      "openstack_lb_pool_v2.pool"
    ]
}

# Create health monitor for check services instances status
resource "openstack_lb_monitor_v2" "monitor" {
  name            = "monitor_http"
  pool_id         = "${openstack_lb_pool_v2.pool.id}"
  type            = "TCP"
  delay           = 2
  timeout         = 2
  max_retries     = 2
  depends_on      = [
      "openstack_lb_member_v2.members"
    ]
}
