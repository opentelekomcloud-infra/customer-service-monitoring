# Create loadbalancer
resource "opentelekomcloud_lb_loadbalancer_v2" "loadbalancer" {
  name          = "${local.workspace_prefix}elastic_loadbalancer_http"
  vip_subnet_id = var.subnet_id
  vip_address   = var.loadbalancer_local_ip
  depends_on = [
    opentelekomcloud_compute_instance_v2.http
  ]
}

# Assign FIP to Loadbalancer
resource opentelekomcloud_networking_floatingip_associate_v2 "floatingip_associate_lb" {
  floating_ip = var.loadbalancer_public_ip
  port_id     = opentelekomcloud_lb_loadbalancer_v2.loadbalancer.vip_port_id
}

output "scn4_lb_fip" {
  value = var.loadbalancer_public_ip
}

# Create Autoscaling group
resource "opentelekomcloud_as_group_v1" "autoscaling_group_with_lb" {
  scaling_group_name = "autoscaling_group_with_lb"
  scaling_configuration_id = opentelekomcloud_as_configuration_v1.as_config.id
  desire_instance_number = 2
  min_instance_number = 0
  max_instance_number = 10
  networks {
    id = var.network_id
  }
  security_groups {
    id = var.bastion_sec_group_id
  }
  vpc_id = var.network_id
  lbaas_listeners = opentelekomcloud_lb_listener_v2.listener.id
  delete_publicip = true
  delete_instances = "yes"
}

resource "opentelekomcloud_as_configuration_v1" "as_config" {
  scaling_configuration_name = "as_config"
  instance_config = {
    instance_id = opentelekomcloud_compute_instance_v2.http.id
    key_name = var.key_pair_name
  }
}

resource "opentelekomcloud_as_policy_v1" "alarm_scaling_policy" {
  scaling_group_id = opentelekomcloud_as_group_v1.autoscaling_group_with_lb.id
  scaling_policy_name = "alarm_policy"
  scaling_policy_type = "ALARM"
  alarm_id = opentelekomcloud_ces_alarmrule.alarm.id
  scaling_policy_action {
    operation = "ADD"
    instance_number = 2
  }
}

resource "opentelekomcloud_ces_alarmrule" "alarm" {
  alarm_name = "alarm_cpu_rule"
  condition {
    comparison_operator = ">"
    count = 1
    filter = "above"
    period = 60
    value = 50
  }
  metric {
    metric_name = "cpu_util"
    namespace = "SYS.ECS"
    dimensions {
      name = "instance_id"
      value = opentelekomcloud_compute_instance_v2.http.id
    }
  }
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
  timeouts {
    create = "5m"
    update = "5m"
    delete = "5m"
  }
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
