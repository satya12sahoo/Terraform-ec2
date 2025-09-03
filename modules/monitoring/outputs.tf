output "sns_topic_arn" {
  description = "SNS topic ARN used for alarm notifications"
  value       = try(aws_sns_topic.this[0].arn, var.sns_topic_arn)
}

output "alarm_arns" {
  description = "ARNs of created CloudWatch alarms"
  value       = concat([for a in aws_cloudwatch_metric_alarm.default : a.arn], [for a in aws_cloudwatch_metric_alarm.custom : a.arn])
}

