# =============================================================================
# CLOUDWATCH LOGS OUTPUTS
# =============================================================================

output "cloudwatch_log_group_arns" {
  description = "ARNs of created CloudWatch log groups"
  value = {
    for k, v in aws_cloudwatch_log_group.application_logs : k => v.arn
  }
}

output "cloudwatch_log_group_names" {
  description = "Names of created CloudWatch log groups"
  value = {
    for k, v in aws_cloudwatch_log_group.application_logs : k => v.name
  }
}

# =============================================================================
# S3 LOGGING OUTPUTS
# =============================================================================

output "s3_logging_bucket_arn" {
  description = "ARN of the S3 logging bucket"
  value = var.create_s3_logging_bucket ? aws_s3_bucket.logging_bucket[0].arn : null
}

output "s3_logging_bucket_name" {
  description = "Name of the S3 logging bucket"
  value = var.create_s3_logging_bucket ? aws_s3_bucket.logging_bucket[0].bucket : null
}

output "s3_logging_bucket_id" {
  description = "ID of the S3 logging bucket"
  value = var.create_s3_logging_bucket ? aws_s3_bucket.logging_bucket[0].id : null
}

# =============================================================================
# LOGGING IAM OUTPUTS
# =============================================================================

output "logging_iam_role_arn" {
  description = "ARN of the logging IAM role"
  value = var.create_logging_iam_role ? aws_iam_role.logging_role[0].arn : null
}

output "logging_iam_role_name" {
  description = "Name of the logging IAM role"
  value = var.create_logging_iam_role ? aws_iam_role.logging_role[0].name : null
}

output "logging_instance_profile_arn" {
  description = "ARN of the logging instance profile"
  value = var.create_logging_iam_role ? aws_iam_instance_profile.logging_profile[0].arn : null
}

output "logging_instance_profile_name" {
  description = "Name of the logging instance profile"
  value = var.create_logging_iam_role ? aws_iam_instance_profile.logging_profile[0].name : null
}

# =============================================================================
# LOGGING AGENT OUTPUTS
# =============================================================================

output "logging_agent_config_parameter_arn" {
  description = "ARN of the logging agent configuration parameter"
  value = var.create_logging_agent_config ? aws_ssm_parameter.logging_agent_config[0].arn : null
}

output "logging_agent_config_parameter_name" {
  description = "Name of the logging agent configuration parameter"
  value = var.create_logging_agent_config ? aws_ssm_parameter.logging_agent_config[0].name : null
}

# =============================================================================
# LOGGING ALARMS OUTPUTS
# =============================================================================

output "logging_alarm_arns" {
  description = "ARNs of created logging alarms"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.log_errors : k => v.arn
  }
}

output "logging_alarm_names" {
  description = "Names of created logging alarms"
  value = {
    for k, v in aws_cloudwatch_metric_alarm.log_errors : k => v.alarm_name
  }
}

# =============================================================================
# LOGGING SNS OUTPUTS
# =============================================================================

output "logging_sns_topic_arn" {
  description = "ARN of the logging SNS topic"
  value = var.create_logging_sns_topic ? aws_sns_topic.logging_notifications[0].arn : null
}

output "logging_sns_topic_name" {
  description = "Name of the logging SNS topic"
  value = var.create_logging_sns_topic ? aws_sns_topic.logging_notifications[0].name : null
}

# =============================================================================
# LOGGING DASHBOARD OUTPUTS
# =============================================================================

output "logging_dashboard_arn" {
  description = "ARN of the logging dashboard"
  value = var.create_logging_dashboard ? aws_cloudwatch_dashboard.logging_dashboard[0].dashboard_arn : null
}

output "logging_dashboard_name" {
  description = "Name of the logging dashboard"
  value = var.create_logging_dashboard ? aws_cloudwatch_dashboard.logging_dashboard[0].dashboard_name : null
}

# =============================================================================
# COMPREHENSIVE OUTPUTS
# =============================================================================

output "logging_enabled" {
  description = "Whether logging module is enabled"
  value = var.create_cloudwatch_log_groups || var.create_s3_logging_bucket || var.create_logging_iam_role || var.create_logging_agent_config || var.create_logging_alarms || var.create_logging_sns_topic || var.create_logging_dashboard
}

output "logging_summary" {
  description = "Comprehensive summary of all logging resources"
  value = {
    enabled = var.create_cloudwatch_log_groups || var.create_s3_logging_bucket || var.create_logging_iam_role || var.create_logging_agent_config || var.create_logging_alarms || var.create_logging_sns_topic || var.create_logging_dashboard
    cloudwatch_log_groups = {
      created = var.create_cloudwatch_log_groups
      count = var.create_cloudwatch_log_groups ? length(aws_cloudwatch_log_group.application_logs) : 0
      names = var.create_cloudwatch_log_groups ? [for k, v in aws_cloudwatch_log_group.application_logs : v.name] : []
    }
    s3_logging_bucket = {
      created = var.create_s3_logging_bucket
      name = var.create_s3_logging_bucket ? aws_s3_bucket.logging_bucket[0].bucket : null
      arn = var.create_s3_logging_bucket ? aws_s3_bucket.logging_bucket[0].arn : null
    }
    iam_role = {
      created = var.create_logging_iam_role
      name = var.create_logging_iam_role ? aws_iam_role.logging_role[0].name : null
      arn = var.create_logging_iam_role ? aws_iam_role.logging_role[0].arn : null
    }
    instance_profile = {
      created = var.create_logging_iam_role
      name = var.create_logging_iam_role ? aws_iam_instance_profile.logging_profile[0].name : null
      arn = var.create_logging_iam_role ? aws_iam_instance_profile.logging_profile[0].arn : null
    }
    agent_config = {
      created = var.create_logging_agent_config
      parameter_name = var.create_logging_agent_config ? aws_ssm_parameter.logging_agent_config[0].name : null
    }
    alarms = {
      created = var.create_logging_alarms
      count = var.create_logging_alarms ? length(aws_cloudwatch_metric_alarm.log_errors) : 0
      names = var.create_logging_alarms ? [for k, v in aws_cloudwatch_metric_alarm.log_errors : v.alarm_name] : []
    }
    sns_topic = {
      created = var.create_logging_sns_topic
      name = var.create_logging_sns_topic ? aws_sns_topic.logging_notifications[0].name : null
      arn = var.create_logging_sns_topic ? aws_sns_topic.logging_notifications[0].arn : null
    }
    dashboard = {
      created = var.create_logging_dashboard
      name = var.create_logging_dashboard ? aws_cloudwatch_dashboard.logging_dashboard[0].dashboard_name : null
      arn = var.create_logging_dashboard ? aws_cloudwatch_dashboard.logging_dashboard[0].dashboard_arn : null
    }
    monitored_instances = {
      count = length(var.instance_ids)
      ids = var.instance_ids
    }
  }
}