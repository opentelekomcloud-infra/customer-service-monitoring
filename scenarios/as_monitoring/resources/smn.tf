resource "opentelekomcloud_ces_alarmrule" "ces_rule" {
  alarm_name        = "${var.scenario}_ces_rule"
  alarm_description = "AutoScaling instances CES rule"

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
      value = opentelekomcloud_as_group_v1.as_group_with_lb.id
    }
  }
  alarm_action_enabled = true
  alarm_actions {
    notification_list = [
    opentelekomcloud_smn_topic_v2.autoscaling_topic.topic_urn]
    type = "notification"
  }
  ok_actions {
    notification_list = [
    opentelekomcloud_smn_topic_v2.autoscaling_topic.topic_urn]
    type = "notification"
  }
  alarm_enabled = true
  depends_on = [
    opentelekomcloud_as_group_v1.as_group_with_lb
  ]
}

resource "opentelekomcloud_smn_topic_v2" "autoscaling_topic" {
  name         = "${var.scenario}_smn_topic"
  display_name = "Topic for AutoScaling monitoring scenario"
}

resource "opentelekomcloud_smn_subscription_v2" "subscription_v1" {
  topic_urn = opentelekomcloud_smn_topic_v2.autoscaling_topic.id
  endpoint  = "http://${var.controller_ip}/smn"
  protocol  = "http"
}

resource "opentelekomcloud_smn_subscription_v2" "subscription_v2" {
  topic_urn = opentelekomcloud_smn_topic_v2.autoscaling_topic.id
  endpoint  = "http://${var.controller_ip}/smn/"
  protocol  = "http"
}
