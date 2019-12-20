resource "opentelekomcloud_ces_alarmrule" "instances_count" {
  alarm_name = "${var.prefix}_instances_count"
  condition {
    comparison_operator = ">="
    count               = 1
    filter              = "average"
    period              = 1
    value               = 2
    unit                = "count"
  }
  metric {
    metric_name = "instance_num"
    namespace   = "SYS.AS"
    dimensions {
      name  = "AutoScalingGroup"
      value = opentelekomcloud_as_group_v1.autoscaling_group_with_lb.id
    }
  }
  alarm_action_enabled = true
  alarm_actions {
    notification_list = [ opentelekomcloud_smn_topic_v2.instances_count_topic.topic_urn ]
    type              = "notification"
  }
  ok_actions {
    notification_list = [ opentelekomcloud_smn_topic_v2.instances_count_topic.topic_urn ]
    type              = "notification"
  }
  alarm_description = "as instances notification"
  alarm_enabled     = true
  depends_on = [
    opentelekomcloud_as_group_v1.autoscaling_group_with_lb
  ]
}

resource "opentelekomcloud_smn_topic_v2" "instances_count_topic" {
  name            = "${var.prefix}_instances_count_topic"
  display_name    = "Topic for scenario4"
}

resource "opentelekomcloud_smn_subscription_v2" "subscription" {
  topic_urn       = "${opentelekomcloud_smn_topic_v2.instances_count_topic.id}"
  endpoint        = "http://${var.bastion_eip}/smn"
  protocol        = "http"
}
