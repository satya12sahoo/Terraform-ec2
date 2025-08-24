output "instance_ids" {
  description = "Map of instance names to their IDs"
  value = {
    for k, v in module.ec2_instances : k => v.instance_id
  }
}

output "instance_private_ips" {
  description = "Map of instance names to their private IP addresses"
  value = {
    for k, v in module.ec2_instances : k => v.private_ip
  }
}

output "instance_public_ips" {
  description = "Map of instance names to their public IP addresses"
  value = {
    for k, v in module.ec2_instances : k => v.public_ip
  }
}

output "instance_availability_zones" {
  description = "Map of instance names to their availability zones"
  value = {
    for k, v in module.ec2_instances : k => v.instance_availability_zone
  }
}

output "instance_arns" {
  description = "Map of instance names to their ARNs"
  value = {
    for k, v in module.ec2_instances : k => v.instance_arn
  }
}

output "instance_tags" {
  description = "Map of instance names to their tags"
  value = {
    for k, v in module.ec2_instances : k => v.instance_tags
  }
}

output "total_instances" {
  description = "Total number of instances created"
  value = length(module.ec2_instances)
}

output "instance_configurations" {
  description = "Map of instance names to their configurations"
  value = {
    for k, v in module.ec2_instances : k => {
      instance_type = v.instance_type
      ami           = v.ami
      subnet_id     = v.subnet_id
      tags          = v.instance_tags
    }
  }
}

output "instances_by_role" {
  description = "Instances grouped by their role tag"
  value = {
    for role in distinct([
      for k, v in module.ec2_instances : v.instance_tags["Role"]
    ]) : role => [
      for k, v in module.ec2_instances : k
      if v.instance_tags["Role"] == role
    ]
  }
}

# IAM Instance Profile outputs
output "iam_instance_profile_arn" {
  description = "ARN of the created IAM instance profile"
  value = var.create_instance_profile_for_existing_role && var.existing_iam_role_name != null ? 
    aws_iam_instance_profile.existing_role[0].arn : null
}

output "iam_instance_profile_name" {
  description = "Name of the created IAM instance profile"
  value = var.create_instance_profile_for_existing_role && var.existing_iam_role_name != null ? 
    aws_iam_instance_profile.existing_role[0].name : null
}

output "iam_instance_profile_id" {
  description = "ID of the created IAM instance profile"
  value = var.create_instance_profile_for_existing_role && var.existing_iam_role_name != null ? 
    aws_iam_instance_profile.existing_role[0].id : null
}

output "existing_iam_role_arn" {
  description = "ARN of the existing IAM role"
  value = var.create_instance_profile_for_existing_role && var.existing_iam_role_name != null ? 
    data.aws_iam_role.existing[0].arn : null
}

output "existing_iam_role_name" {
  description = "Name of the existing IAM role"
  value = var.create_instance_profile_for_existing_role && var.existing_iam_role_name != null ? 
    data.aws_iam_role.existing[0].name : null
}

# Smart IAM outputs
output "smart_iam_instance_profile_arn" {
  description = "ARN of the smart IAM instance profile"
  value = var.enable_smart_iam && var.smart_iam_role_name != null ? 
    aws_iam_instance_profile.smart_profile[0].arn : null
}

output "smart_iam_instance_profile_name" {
  description = "Name of the smart IAM instance profile"
  value = var.enable_smart_iam && var.smart_iam_role_name != null ? 
    aws_iam_instance_profile.smart_profile[0].name : null
}

output "smart_iam_instance_profile_id" {
  description = "ID of the smart IAM instance profile"
  value = var.enable_smart_iam && var.smart_iam_role_name != null ? 
    aws_iam_instance_profile.smart_profile[0].id : null
}

output "smart_iam_role_arn" {
  description = "ARN of the smart IAM role (if created)"
  value = var.enable_smart_iam && var.smart_iam_role_name != null && length(aws_iam_role.smart_role) > 0 ? 
    aws_iam_role.smart_role[0].arn : null
}

output "smart_iam_role_name" {
  description = "Name of the smart IAM role (if created)"
  value = var.enable_smart_iam && var.smart_iam_role_name != null && length(aws_iam_role.smart_role) > 0 ? 
    aws_iam_role.smart_role[0].name : null
}

output "smart_iam_role_id" {
  description = "ID of the smart IAM role (if created)"
  value = var.enable_smart_iam && var.smart_iam_role_name != null && length(aws_iam_role.smart_role) > 0 ? 
    aws_iam_role.smart_role[0].id : null
}

output "smart_iam_existing_role_arn" {
  description = "ARN of the existing IAM role (if found in smart mode)"
  value = var.enable_smart_iam && var.smart_iam_role_name != null && length(data.aws_iam_role.smart_existing_role) > 0 ? 
    data.aws_iam_role.smart_existing_role[0].arn : null
}

output "smart_iam_existing_profile_arn" {
  description = "ARN of the existing IAM instance profile (if found in smart mode)"
  value = var.enable_smart_iam && var.smart_iam_role_name != null && length(data.aws_iam_instance_profile.smart_existing_profile) > 0 ? 
    data.aws_iam_instance_profile.smart_existing_profile[0].arn : null
}

output "smart_iam_decision" {
  description = "Smart IAM decision made by the wrapper"
  value = var.enable_smart_iam && var.smart_iam_role_name != null ? (
    length(data.aws_iam_role.smart_existing_role) > 0 ? "Used existing IAM role" : (
      length(data.aws_iam_instance_profile.smart_existing_profile) > 0 ? "Created IAM role for existing instance profile" : (
        length(aws_iam_role.smart_role) > 0 ? "Created new IAM role and instance profile" : "No action taken"
      )
    )
  ) : "Smart IAM not enabled"
}

output "final_instance_profile_used" {
  description = "Final instance profile name used by all instances"
  value = local.instance_profile_name
}

# Security Group Outputs
output "security_group_id" {
  description = "ID of the created security group (if any)"
  value = var.create_security_group ? try(module.ec2_instances[keys(var.instances)[0]].security_group_id, null) : null
}

output "security_group_arn" {
  description = "ARN of the created security group (if any)"
  value = var.create_security_group ? try(module.ec2_instances[keys(var.instances)[0]].security_group_arn, null) : null
}

output "security_group_name" {
  description = "Name of the created security group (if any)"
  value = var.create_security_group ? try(module.ec2_instances[keys(var.instances)[0]].security_group_name, null) : null
}

output "security_group_vpc_id" {
  description = "VPC ID of the created security group (if any)"
  value = var.create_security_group ? try(module.ec2_instances[keys(var.instances)[0]].security_group_vpc_id, null) : null
}

output "security_group_ingress_rules" {
  description = "Ingress rules of the created security group (if any)"
  value = var.create_security_group ? try(module.ec2_instances[keys(var.instances)[0]].security_group_ingress_rules, {}) : {}
}

output "security_group_egress_rules" {
  description = "Egress rules of the created security group (if any)"
  value = var.create_security_group ? try(module.ec2_instances[keys(var.instances)[0]].security_group_egress_rules, {}) : {}
}

output "final_security_groups_used" {
  description = "Final security groups used by all instances"
  value = {
    for instance_name, instance_config in var.instances : instance_name => instance_config.vpc_security_group_ids
  }
}

output "security_group_creation_summary" {
  description = "Summary of security group creation and usage"
  value = {
    create_security_group = var.create_security_group
    security_group_name = var.security_group_name
    security_group_vpc_id = var.security_group_vpc_id
    instances_with_security_groups = {
      for instance_name, instance_config in var.instances : instance_name => {
        security_group_ids = instance_config.vpc_security_group_ids
        count = length(instance_config.vpc_security_group_ids)
      }
    }
  }
}

# Monitoring Module Outputs
output "monitoring_enabled" {
  description = "Whether monitoring module is enabled"
  value = var.enable_monitoring_module
}

output "cloudwatch_agent_role_arn" {
  description = "ARN of the CloudWatch agent IAM role"
  value = var.enable_monitoring_module ? module.monitoring[0].cloudwatch_agent_role_arn : null
}

output "cloudwatch_agent_instance_profile_name" {
  description = "Name of the CloudWatch agent instance profile"
  value = var.enable_monitoring_module ? module.monitoring[0].cloudwatch_agent_instance_profile_name : null
}

output "dashboard_arn" {
  description = "ARN of the CloudWatch dashboard"
  value = var.enable_monitoring_module ? module.monitoring[0].dashboard_arn : null
}

output "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  value = var.enable_monitoring_module ? module.monitoring[0].dashboard_name : null
}

output "all_alarm_arns" {
  description = "ARNs of all CloudWatch alarms"
  value = var.enable_monitoring_module ? module.monitoring[0].all_alarm_arns : []
}

output "all_alarm_names" {
  description = "Names of all CloudWatch alarms"
  value = var.enable_monitoring_module ? module.monitoring[0].all_alarm_names : []
}

output "log_group_names" {
  description = "Names of CloudWatch log groups"
  value = var.enable_monitoring_module ? module.monitoring[0].log_group_names : []
}

output "sns_topic_arn" {
  description = "ARN of the SNS topic for alarm notifications"
  value = var.enable_monitoring_module ? module.monitoring[0].sns_topic_arn : null
}

output "monitoring_summary" {
  description = "Summary of monitoring resources created"
  value = var.enable_monitoring_module ? module.monitoring[0].monitoring_summary : null
}

# =============================================================================
# LOGGING MODULE OUTPUTS
# =============================================================================

output "logging_enabled" {
  description = "Whether logging module is enabled"
  value = var.enable_logging_module
}

output "logging_cloudwatch_log_group_arns" {
  description = "ARNs of created CloudWatch log groups from logging module"
  value = var.enable_logging_module ? module.logging[0].cloudwatch_log_group_arns : {}
}

output "logging_cloudwatch_log_group_names" {
  description = "Names of created CloudWatch log groups from logging module"
  value = var.enable_logging_module ? module.logging[0].cloudwatch_log_group_names : {}
}

output "logging_s3_bucket_arn" {
  description = "ARN of the S3 logging bucket"
  value = var.enable_logging_module ? module.logging[0].s3_logging_bucket_arn : null
}

output "logging_s3_bucket_name" {
  description = "Name of the S3 logging bucket"
  value = var.enable_logging_module ? module.logging[0].s3_logging_bucket_name : null
}

output "logging_iam_role_arn" {
  description = "ARN of the logging IAM role"
  value = var.enable_logging_module ? module.logging[0].logging_iam_role_arn : null
}

output "logging_iam_role_name" {
  description = "Name of the logging IAM role"
  value = var.enable_logging_module ? module.logging[0].logging_iam_role_name : null
}

output "logging_instance_profile_arn" {
  description = "ARN of the logging instance profile"
  value = var.enable_logging_module ? module.logging[0].logging_instance_profile_arn : null
}

output "logging_instance_profile_name" {
  description = "Name of the logging instance profile"
  value = var.enable_logging_module ? module.logging[0].logging_instance_profile_name : null
}

output "logging_agent_config_parameter_name" {
  description = "Name of the logging agent configuration parameter"
  value = var.enable_logging_module ? module.logging[0].logging_agent_config_parameter_name : null
}

output "logging_alarm_arns" {
  description = "ARNs of created logging alarms"
  value = var.enable_logging_module ? module.logging[0].logging_alarm_arns : {}
}

output "logging_alarm_names" {
  description = "Names of created logging alarms"
  value = var.enable_logging_module ? module.logging[0].logging_alarm_names : {}
}

output "logging_sns_topic_arn" {
  description = "ARN of the logging SNS topic"
  value = var.enable_logging_module ? module.logging[0].logging_sns_topic_arn : null
}

output "logging_sns_topic_name" {
  description = "Name of the logging SNS topic"
  value = var.enable_logging_module ? module.logging[0].logging_sns_topic_name : null
}

output "logging_dashboard_arn" {
  description = "ARN of the logging dashboard"
  value = var.enable_logging_module ? module.logging[0].logging_dashboard_arn : null
}

output "logging_dashboard_name" {
  description = "Name of the logging dashboard"
  value = var.enable_logging_module ? module.logging[0].logging_dashboard_name : null
}

output "logging_summary" {
  description = "Comprehensive summary of all logging resources"
  value = var.enable_logging_module ? module.logging[0].logging_summary : null
}