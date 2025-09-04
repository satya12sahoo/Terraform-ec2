# EC2 Monitoring Module Outputs

output "iam_role_arn" {
  description = "ARN of the CloudWatch agent IAM role"
  value       = var.create_iam_role ? aws_iam_role.cloudwatch_agent_role[0].arn : null
}

output "iam_role_name" {
  description = "Name of the CloudWatch agent IAM role"
  value       = var.create_iam_role ? aws_iam_role.cloudwatch_agent_role[0].name : null
}

output "iam_instance_profile_arn" {
  description = "ARN of the CloudWatch agent IAM instance profile"
  value       = var.create_iam_role ? aws_iam_instance_profile.cloudwatch_agent_profile[0].arn : null
}

output "iam_instance_profile_name" {
  description = "Name of the CloudWatch agent IAM instance profile"
  value       = var.create_iam_role ? aws_iam_instance_profile.cloudwatch_agent_profile[0].name : null
}

output "ssm_parameter_arn" {
  description = "ARN of the CloudWatch agent configuration SSM parameter"
  value       = var.create_ssm_parameter ? aws_ssm_parameter.cloudwatch_agent_config[0].arn : null
}

output "ssm_parameter_name" {
  description = "Name of the CloudWatch agent configuration SSM parameter"
  value       = var.create_ssm_parameter ? aws_ssm_parameter.cloudwatch_agent_config[0].name : null
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch monitoring dashboard"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.ec2_monitoring_dashboard[0].dashboard_arn : null
}

output "dashboard_name" {
  description = "Name of the CloudWatch monitoring dashboard"
  value       = var.create_dashboard ? aws_cloudwatch_dashboard.ec2_monitoring_dashboard[0].dashboard_name : null
}

output "log_group_arn" {
  description = "ARN of the CloudWatch log group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.ec2_logs[0].arn : null
}

output "log_group_name" {
  description = "Name of the CloudWatch log group"
  value       = var.create_log_group ? aws_cloudwatch_log_group.ec2_logs[0].name : null
}

output "cpu_alarm_arn" {
  description = "ARN of the CPU utilization CloudWatch alarm"
  value       = var.create_cpu_alarm ? aws_cloudwatch_metric_alarm.high_cpu_alarm[0].arn : null
}

output "memory_alarm_arn" {
  description = "ARN of the memory utilization CloudWatch alarm"
  value       = var.create_memory_alarm ? aws_cloudwatch_metric_alarm.high_memory_alarm[0].arn : null
}

output "cloudwatch_agent_config" {
  description = "The CloudWatch agent configuration JSON"
  value       = var.cloudwatch_agent_config
}