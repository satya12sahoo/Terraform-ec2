locals {
  alarm_name = "${var.name_prefix}-cpu-high"
  alarm_desc = "CPUUtilization exceeds ${var.alarm_cpu_threshold}% for ${var.alarm_eval_periods}x${var.alarm_period_seconds}s on instance ${var.instance_id}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = local.alarm_name
  alarm_description   = local.alarm_desc
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.alarm_eval_periods
  threshold           = var.alarm_cpu_threshold
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.alarm_period_seconds
  statistic           = "Average"

  dimensions = {
    InstanceId = var.instance_id
  }

  treat_missing_data = "notBreaching"

  alarm_actions = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
  ok_actions    = var.sns_topic_arn != null ? [var.sns_topic_arn] : []
}

output "alarm_name" {
  value = aws_cloudwatch_metric_alarm.cpu_high.alarm_name
}

