# Comprehensive Monitoring Module for EC2 Instances
# This module provides CloudWatch monitoring, alarms, dashboards, and logging

# CloudWatch Agent IAM Role
resource "aws_iam_role" "cloudwatch_agent" {
  count = var.create_cloudwatch_agent_role ? 1 : 0
  
  name = var.cloudwatch_agent_role_use_name_prefix ? null : var.cloudwatch_agent_role_name
  name_prefix = var.cloudwatch_agent_role_use_name_prefix ? var.cloudwatch_agent_role_name_prefix : null
  path = var.cloudwatch_agent_role_path
  description = var.cloudwatch_agent_role_description
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = merge(
    var.cloudwatch_agent_role_tags,
    {
      Name        = var.cloudwatch_agent_role_use_name_prefix ? null : var.cloudwatch_agent_role_name
      Purpose     = "CloudWatch Agent"
      ManagedBy   = "terraform"
    }
  )
}

# CloudWatch Agent IAM Instance Profile
resource "aws_iam_instance_profile" "cloudwatch_agent" {
  count = var.create_cloudwatch_agent_role ? 1 : 0
  
  name = var.cloudwatch_agent_instance_profile_use_name_prefix ? null : (
    var.cloudwatch_agent_instance_profile_name != null ? var.cloudwatch_agent_instance_profile_name : "${var.cloudwatch_agent_role_name}-profile"
  )
  name_prefix = var.cloudwatch_agent_instance_profile_use_name_prefix ? var.cloudwatch_agent_instance_profile_name_prefix : null
  path = var.cloudwatch_agent_instance_profile_path
  role = aws_iam_role.cloudwatch_agent[0].name
  
  tags = merge(
    var.cloudwatch_agent_instance_profile_tags,
    {
      Name        = var.cloudwatch_agent_instance_profile_use_name_prefix ? null : (
        var.cloudwatch_agent_instance_profile_name != null ? var.cloudwatch_agent_instance_profile_name : "${var.cloudwatch_agent_role_name}-profile"
      )
      Purpose     = "CloudWatch Agent Profile"
      ManagedBy   = "terraform"
    }
  )
}

# Attach CloudWatch Agent policies
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policies" {
  for_each = var.create_cloudwatch_agent_role ? var.cloudwatch_agent_policies : {}
  
  role       = aws_iam_role.cloudwatch_agent[0].name
  policy_arn = each.value
}

# CloudWatch Dashboard
resource "aws_cloudwatch_dashboard" "ec2_dashboard" {
  count = var.create_dashboard ? 1 : 0
  
  dashboard_name = var.dashboard_use_name_prefix ? null : var.dashboard_name
  dashboard_name_prefix = var.dashboard_use_name_prefix ? var.dashboard_name_prefix : null
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            for instance_id in var.instance_ids : [
              "AWS/EC2",
              "CPUUtilization",
              "InstanceId",
              instance_id
            ]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 CPU Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            for instance_id in var.instance_ids : [
              "AWS/EC2",
              "NetworkIn",
              "InstanceId",
              instance_id
            ]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 Network In"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            for instance_id in var.instance_ids : [
              "AWS/EC2",
              "NetworkOut",
              "InstanceId",
              instance_id
            ]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 Network Out"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 6
        width  = 12
        height = 6
        properties = {
          metrics = [
            for instance_id in var.instance_ids : [
              "AWS/EC2",
              "DiskReadOps",
              "InstanceId",
              instance_id
            ]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 Disk Read Operations"
        }
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "cpu_utilization" {
  for_each = var.create_cpu_alarms ? { for id in var.instance_ids : id => id } : {}
  
  alarm_name = var.cpu_alarm_use_name_prefix ? null : (
    var.cpu_alarm_name != null ? "${var.cpu_alarm_name}-${each.value}" : "cpu-utilization-${each.value}"
  )
  alarm_name_prefix = var.cpu_alarm_use_name_prefix ? var.cpu_alarm_name_prefix : null
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cpu_alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = var.cpu_alarm_description
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  
  dimensions = {
    InstanceId = each.value
  }
  
  tags = merge(
    var.cpu_alarm_tags,
    var.alarm_tags,
    {
      Name        = var.cpu_alarm_use_name_prefix ? null : (
        var.cpu_alarm_name != null ? "${var.cpu_alarm_name}-${each.value}" : "cpu-utilization-${each.value}"
      )
      InstanceId  = each.value
      Metric      = "CPUUtilization"
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  for_each = var.create_memory_alarms ? { for id in var.instance_ids : id => id } : {}
  
  alarm_name = var.memory_alarm_use_name_prefix ? null : (
    var.memory_alarm_name != null ? "${var.memory_alarm_name}-${each.value}" : "memory-utilization-${each.value}"
  )
  alarm_name_prefix = var.memory_alarm_use_name_prefix ? var.memory_alarm_name_prefix : null
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.memory_alarm_evaluation_periods
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = var.memory_alarm_period
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold
  alarm_description   = var.memory_alarm_description
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  
  dimensions = {
    InstanceId = each.value
  }
  
  tags = merge(
    var.memory_alarm_tags,
    var.alarm_tags,
    {
      Name        = var.memory_alarm_use_name_prefix ? null : (
        var.memory_alarm_name != null ? "${var.memory_alarm_name}-${each.value}" : "memory-utilization-${each.value}"
      )
      InstanceId  = each.value
      Metric      = "MemoryUtilization"
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "disk_utilization" {
  for_each = var.create_disk_alarms ? { for id in var.instance_ids : id => id } : {}
  
  alarm_name = var.disk_alarm_use_name_prefix ? null : (
    var.disk_alarm_name != null ? "${var.disk_alarm_name}-${each.value}" : "disk-utilization-${each.value}"
  )
  alarm_name_prefix = var.disk_alarm_use_name_prefix ? var.disk_alarm_name_prefix : null
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.disk_alarm_evaluation_periods
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = var.disk_alarm_period
  statistic           = "Average"
  threshold           = var.disk_alarm_threshold
  alarm_description   = var.disk_alarm_description
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  
  dimensions = {
    InstanceId = each.value
  }
  
  tags = merge(
    var.disk_alarm_tags,
    var.alarm_tags,
    {
      Name        = var.disk_alarm_use_name_prefix ? null : (
        var.disk_alarm_name != null ? "${var.disk_alarm_name}-${each.value}" : "disk-utilization-${each.value}"
      )
      InstanceId  = each.value
      Metric      = "DiskUtilization"
      ManagedBy   = "terraform"
    }
  )
}

# CloudWatch Log Groups
resource "aws_cloudwatch_log_group" "application_logs" {
  for_each = var.create_log_groups ? var.log_groups : {}
  
  name              = each.value.name
  retention_in_days = each.value.retention_in_days
  kms_key_id        = each.value.kms_key_id
  
  tags = merge(
    each.value.tags,
    {
      Name        = each.value.name
      Purpose     = "Application Logs"
      ManagedBy   = "terraform"
    }
  )
}

# SNS Topic for Alarms
resource "aws_sns_topic" "alarm_notifications" {
  count = var.create_sns_topic ? 1 : 0
  
  name = var.sns_topic_use_name_prefix ? null : var.sns_topic_name
  name_prefix = var.sns_topic_use_name_prefix ? var.sns_topic_name_prefix : null
  tags = merge(
    var.sns_topic_tags,
    {
      Name        = var.sns_topic_use_name_prefix ? null : var.sns_topic_name
      Purpose     = "Alarm Notifications"
      ManagedBy   = "terraform"
    }
  )
}

# SNS Topic Subscription
resource "aws_sns_topic_subscription" "alarm_notifications" {
  for_each = var.create_sns_topic ? var.sns_subscriptions : {}
  
  topic_arn = aws_sns_topic.alarm_notifications[0].arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
  
  filter_policy = each.value.filter_policy
}

# CloudWatch Agent Configuration
locals {
  # Default log groups configuration
  default_log_groups = {
    system = {
      file_path = "/var/log/messages"
      log_group_name = "/aws/ec2/${var.environment}/system"
      log_stream_name = "{instance_id}"
      timezone = "UTC"
    }
    security = {
      file_path = "/var/log/secure"
      log_group_name = "/aws/ec2/${var.environment}/security"
      log_stream_name = "{instance_id}"
      timezone = "UTC"
    }
    application = {
      file_path = "/var/log/application.log"
      log_group_name = "/aws/ec2/${var.environment}/application"
      log_stream_name = "{instance_id}"
      timezone = "UTC"
    }
  }
  
  # Default metrics configuration
  default_metrics = {
    cpu = {
      measurement = ["cpu_usage_idle", "cpu_usage_iowait", "cpu_usage_user", "cpu_usage_system"]
      metrics_collection_interval = 60
      resources = ["*"]
    }
    disk = {
      measurement = ["used_percent"]
      metrics_collection_interval = 60
      resources = ["*"]
    }
    diskio = {
      measurement = ["io_time"]
      metrics_collection_interval = 60
      resources = ["*"]
    }
    mem = {
      measurement = ["mem_used_percent"]
      metrics_collection_interval = 60
    }
    netstat = {
      measurement = ["tcp_established", "tcp_time_wait"]
      metrics_collection_interval = 60
    }
    swap = {
      measurement = ["swap_used_percent"]
      metrics_collection_interval = 60
    }
  }
  
  # Merge custom configurations with defaults
  custom_log_groups = length(var.cloudwatch_agent_config_log_groups) > 0 ? var.cloudwatch_agent_config_log_groups : local.default_log_groups
  custom_metrics = length(var.cloudwatch_agent_config_metrics) > 0 ? var.cloudwatch_agent_config_metrics : local.default_metrics
  
  cloudwatch_agent_config = var.create_cloudwatch_agent_config ? {
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            for name, config in local.custom_log_groups : {
              file_path = config.file_path
              log_group_name = config.log_group_name
              log_stream_name = config.log_stream_name
              timezone = config.timezone
            }
          ]
        }
      }
    }
    metrics = {
      metrics_collected = local.custom_metrics
    }
  } : null
}

# CloudWatch Agent Configuration File
resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  count = var.create_cloudwatch_agent_config ? 1 : 0
  
  name = var.cloudwatch_agent_config_parameter_use_name_prefix ? null : var.cloudwatch_agent_config_parameter_name
  name_prefix = var.cloudwatch_agent_config_parameter_use_name_prefix ? var.cloudwatch_agent_config_parameter_name_prefix : null
  type  = "String"
  value = jsonencode(local.cloudwatch_agent_config)
  
  tags = merge(
    var.cloudwatch_agent_config_parameter_tags,
    {
      Name        = var.cloudwatch_agent_config_parameter_use_name_prefix ? null : var.cloudwatch_agent_config_parameter_name
      Purpose     = "CloudWatch Agent Configuration"
      ManagedBy   = "terraform"
    }
  )
}