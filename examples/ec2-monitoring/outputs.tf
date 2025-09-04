# Example EC2 Monitoring Outputs

output "instance_id" {
  description = "ID of the created EC2 instance"
  value       = aws_instance.example.id
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.example.public_ip
}

output "instance_private_ip" {
  description = "Private IP address of the EC2 instance"
  value       = aws_instance.example.private_ip
}

output "security_group_id" {
  description = "ID of the security group attached to the instance"
  value       = aws_security_group.example.id
}

output "monitoring_module_outputs" {
  description = "All outputs from the EC2 monitoring module"
  value = {
    iam_role_arn              = module.ec2_monitoring.iam_role_arn
    iam_role_name             = module.ec2_monitoring.iam_role_name
    iam_instance_profile_arn  = module.ec2_monitoring.iam_instance_profile_arn
    iam_instance_profile_name = module.ec2_monitoring.iam_instance_profile_name
    ssm_parameter_arn         = module.ec2_monitoring.ssm_parameter_arn
    ssm_parameter_name        = module.ec2_monitoring.ssm_parameter_name
    dashboard_arn             = module.ec2_monitoring.dashboard_arn
    dashboard_name            = module.ec2_monitoring.dashboard_name
    log_group_arn             = module.ec2_monitoring.log_group_arn
    log_group_name            = module.ec2_monitoring.log_group_name
    cpu_alarm_arn             = module.ec2_monitoring.cpu_alarm_arn
    memory_alarm_arn          = module.ec2_monitoring.memory_alarm_arn
  }
}

output "cloudwatch_dashboard_url" {
  description = "URL to the CloudWatch monitoring dashboard"
  value       = "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${module.ec2_monitoring.dashboard_name}"
}