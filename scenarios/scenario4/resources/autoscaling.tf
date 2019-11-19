# Create Autoscaling
resource "opentelekomcloud_as_configuration_v1" "as_config" {
  scaling_configuration_name = "${var.prefix}_autoscaled_instance"
  instance_config {
    instance_id = opentelekomcloud_compute_instance_v2.http[0].id
    key_name = var.kp.key_name
    user_data   = file("${path.module}/first_boot.sh")
  }
  depends_on = [
    opentelekomcloud_lb_monitor_v2.monitor
  ]
}

resource "opentelekomcloud_as_group_v1" "autoscaling_group_with_lb" {
  scaling_group_name = "${var.prefix}_autoscaling_group_with_lb"
  scaling_configuration_id = opentelekomcloud_as_configuration_v1.as_config.id
  desire_instance_number = 0
  min_instance_number = 0
  max_instance_number = 2
  networks {
    id = var.network_id
  }
  security_groups {
    id = var.bastion_sec_group_id
  }
  vpc_id = var.router_id
  lbaas_listeners {
    pool_id = opentelekomcloud_lb_pool_v2.pool.id
    protocol_port = 80
    weight = 1
  }
  health_periodic_audit_method = "NOVA_AUDIT"
  health_periodic_audit_time = "5"
  delete_publicip = true
  delete_instances = "yes"
  cool_down_time = 300
  depends_on = [
    opentelekomcloud_as_configuration_v1.as_config
  ]
}

resource "opentelekomcloud_as_policy_v1" "alarm_scaling_policy" {
  scaling_group_id = opentelekomcloud_as_group_v1.autoscaling_group_with_lb.id
  scaling_policy_name = "${var.prefix}_alarm_policy"
  scaling_policy_type = "ALARM"
  alarm_id = opentelekomcloud_ces_alarmrule.alarm.id
  scaling_policy_action {
    operation = "ADD"
    instance_number = 2
  }
  cool_down_time = 60
}

resource "opentelekomcloud_ces_alarmrule" "alarm" {
  alarm_name = "${var.prefix}_alarm_cpu_rule"
  condition {
    comparison_operator = ">="
    count = 1
    filter = "average"
    period = 300
    value = 50
  }
  metric {
    metric_name = "cpu_util"
    namespace = "SYS.ECS"
    dimensions {
      name = "instance_id"
      value = opentelekomcloud_compute_instance_v2.http[0].id
    }
  }
  alarm_action_enabled = true
  alarm_actions {
    notification_list = []
    type = "autoscaling"
  }
  alarm_description = "autoScaling"
  alarm_enabled = true
  depends_on = [
    opentelekomcloud_as_group_v1.autoscaling_group_with_lb
  ]
}

resource "opentelekomcloud_as_policy_v1" "reduce_policy" {
  scaling_group_id = opentelekomcloud_as_group_v1.autoscaling_group_with_lb.id
  scaling_policy_name = "${var.prefix}_reduce_policy"
  scaling_policy_type = "ALARM"
  alarm_id = opentelekomcloud_ces_alarmrule.reduce.id
  scaling_policy_action {
    operation = "REMOVE"
    instance_number = 2
  }
  cool_down_time = 60
}

resource "opentelekomcloud_ces_alarmrule" "reduce" {
  alarm_name = "${var.prefix}_alarm_cpu_rule"
  condition {
    comparison_operator = "<="
    count = 1
    filter = "average"
    period = 300
    value = 50
  }
  metric {
    metric_name = "cpu_util"
    namespace = "SYS.ECS"
    dimensions {
      name = "instance_id"
      value = opentelekomcloud_compute_instance_v2.http[0].id
    }
  }
  alarm_action_enabled = true
  alarm_actions {
    notification_list = []
    type = "autoscaling"
  }
  alarm_description = "autoReducing"
  alarm_enabled = true
  depends_on = [
    opentelekomcloud_as_group_v1.autoscaling_group_with_lb
  ]
}
