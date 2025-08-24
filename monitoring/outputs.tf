# Monitoring Module Outputs

# CloudWatch Agent IAM Role
output "cloudwatch_agent_role_arn" {
  description = "ARN of the CloudWatch agent IAM role"
  value       = var.create_cloudwatch_agent_role ? aws_iam_role.cloudwatch_agent[0].arn : null
}

output "cloudwatch_agent_role_name" {
  description = "Name of the CloudWatch agent IAM role"
  value       = var.create_cloudwatch_agent_role ? aws_iam_role.cloudwatch_agent[0].name : null
}

output "cloudwatch_agent_instance_profile_arn" {
  description = "ARN of the CloudWatch agent instance profile"
  value       = var.create_cloudwatch_agent_role ? aws_iam_instance_profile.cloudwatch_agent[0].arn : null
}

output "cloudwatch_agent_instance_profile_name" {
  description = "Name of the CloudWatch agent instance profile"
  value       = var.create_cloudwatch_agent_role ? aws_iam_instance_profile.cloudwatch_agent[0].name : null
}

# CloudWatch Dashboard
output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.ec2_dashboard[0].dashboard_arn : null
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.ec2_dashboard[0].dashboard_name : null
}

# CloudWatch Alarms
output "cpu_alarm_arns" {
  description = "ARNs of CPU utilization alarms"
  value       = var.create_cpu_alarms ? [for alarm in aws_cloudwatch_metric_alarm.cpu_utilization : alarm.arn] : []
}

output "cpu_alarm_names" {
  description = "Names of CPU utilization alarms"
  value       = var.create_cpu_alarms ? [for alarm in aws_cloudwatch_metric_alarm.cpu_utilization : alarm.alarm_name] : []
}

output "memory_alarm_arns" {
  description = "ARNs of memory utilization alarms"
  value       = var.create_memory_alarms ? [for alarm in aws_cloudwatch_metric_alarm.memory_utilization : alarm.arn] : []
}

output "memory_alarm_names" {
  description = "Names of memory utilization alarms"
  value       = var.create_memory_alarms ? [for alarm in aws_cloudwatch_metric_alarm.memory_utilization : alarm.alarm_name] : []
}

output "disk_alarm_arns" {
  description = "ARNs of disk utilization alarms"
  value       = var.create_disk_alarms ? [for alarm in aws_cloudwatch_metric_alarm.disk_utilization : alarm.arn] : []
}

output "disk_alarm_names" {
  description = "Names of disk utilization alarms"
  value       = var.create_disk_alarms ? [for alarm in aws_cloudwatch_metric_alarm.disk_utilization : alarm.alarm_name] : []
}

output "all_alarm_arns" {
  description = "ARNs of all CloudWatch alarms"
  value       = concat(
    var.create_cpu_alarms ? [for alarm in aws_cloudwatch_metric_alarm.cpu_utilization : alarm.arn] : [],
    var.create_memory_alarms ? [for alarm in aws_cloudwatch_metric_alarm.memory_utilization : alarm.arn] : [],
    var.create_disk_alarms ? [for alarm in aws_cloudwatch_metric_alarm.disk_utilization : alarm.arn] : []
  )
}

output "all_alarm_names" {
  description = "Names of all CloudWatch alarms"
  value       = concat(
    var.create_cpu_alarms ? [for alarm in aws_cloudwatch_metric_alarm.cpu_utilization : alarm.alarm_name] : [],
    var.create_memory_alarms ? [for alarm in aws_cloudwatch_metric_alarm.memory_utilization : alarm.alarm_name] : [],
    var.create_disk_alarms ? [for alarm in aws_cloudwatch_metric_alarm.disk_utilization : alarm.alarm_name] : []
  )
}

# CloudWatch Log Groups
output "log_group_arns" {
  description = "ARNs of CloudWatch log groups"
  value       = var.create_log_groups ? [for log_group in aws_cloudwatch_log_group.application_logs : log_group.arn] : []
}

output "log_group_names" {
  description = "Names of CloudWatch log groups"
  value       = var.create_log_groups ? [for log_group in aws_cloudwatch_log_group.application_logs : log_group.name] : []
}

# SNS Topic
output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  value       = var.create_sns_topic ? aws_sns_topic.alarm_notifications[0].arn : null
}

output "sns_topic_name" {
  description = "Name of the SNS topic for alarm notifications"
  value       = var.create_sns_topic ? aws_sns_topic.alarm_notifications[0].name : null
}

# CloudWatch Agent Configuration
output "cloudwatch_agent_config_parameter_arn" {
  description = "ARN of the CloudWatch agent configuration parameter"
  value       = var.create_cloudwatch_agent_config ? aws_ssm_parameter.cloudwatch_agent_config[0].arn : null
}

output "cloudwatch_agent_config_parameter_name" {
  description = "Name of the CloudWatch agent configuration parameter"
  value       = var.create_cloudwatch_agent_config ? aws_ssm_parameter.cloudwatch_agent_config[0].name : null
}

# Monitoring Summary
output "monitoring_summary" {
  description = "Summary of monitoring resources created"
  value = {
    cloudwatch_agent_role_created = var.create_cloudwatch_agent_role
    dashboard_created             = var.create_dashboard
    cpu_alarms_created           = var.create_cpu_alarms
    memory_alarms_created        = var.create_memory_alarms
    disk_alarms_created          = var.create_disk_alarms
    log_groups_created           = var.create_log_groups
    sns_topic_created            = var.create_sns_topic
    agent_config_created         = var.create_cloudwatch_agent_config
    total_instances_monitored    = length(var.instance_ids)
    total_alarms_created         = length(local.all_alarm_arns)
    total_log_groups_created     = length(local.log_group_names)
  }
}

locals {
  all_alarm_arns = concat(
    var.create_cpu_alarms ? [for alarm in aws_cloudwatch_metric_alarm.cpu_utilization : alarm.arn] : [],
    var.create_memory_alarms ? [for alarm in aws_cloudwatch_metric_alarm.memory_utilization : alarm.arn] : [],
    var.create_disk_alarms ? [for alarm in aws_cloudwatch_metric_alarm.disk_utilization : alarm.arn] : []
  )
  
  log_group_names = var.create_log_groups ? [for log_group in aws_cloudwatch_log_group.application_logs : log_group.name] : []
}