# Comprehensive Monitoring Module for EC2 Instances
# This module provides CloudWatch monitoring, alarms, dashboards, and logging

# CloudWatch Agent IAM Role
resource "aws_iam_role" "cloudwatch_agent" {
  count = var.create_cloudwatch_agent_role ? 1 : 0
  
  name = var.cloudwatch_agent_role_name
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
      Name        = var.cloudwatch_agent_role_name
      Purpose     = "CloudWatch Agent"
      ManagedBy   = "terraform"
    }
  )
}

# CloudWatch Agent IAM Instance Profile
resource "aws_iam_instance_profile" "cloudwatch_agent" {
  count = var.create_cloudwatch_agent_role ? 1 : 0
  
  name = "${var.cloudwatch_agent_role_name}-profile"
  path = var.cloudwatch_agent_role_path
  role = aws_iam_role.cloudwatch_agent[0].name
  
  tags = merge(
    var.cloudwatch_agent_role_tags,
    {
      Name        = "${var.cloudwatch_agent_role_name}-profile"
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
  
  dashboard_name = var.dashboard_name
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
  
  alarm_name          = "cpu-utilization-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cpu_alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "CPU utilization is too high"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  
  dimensions = {
    InstanceId = each.value
  }
  
  tags = merge(
    var.alarm_tags,
    {
      Name        = "cpu-utilization-${each.value}"
      InstanceId  = each.value
      Metric      = "CPUUtilization"
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "memory_utilization" {
  for_each = var.create_memory_alarms ? { for id in var.instance_ids : id => id } : {}
  
  alarm_name          = "memory-utilization-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.memory_alarm_evaluation_periods
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = var.memory_alarm_period
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold
  alarm_description   = "Memory utilization is too high"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  
  dimensions = {
    InstanceId = each.value
  }
  
  tags = merge(
    var.alarm_tags,
    {
      Name        = "memory-utilization-${each.value}"
      InstanceId  = each.value
      Metric      = "MemoryUtilization"
      ManagedBy   = "terraform"
    }
  )
}

resource "aws_cloudwatch_metric_alarm" "disk_utilization" {
  for_each = var.create_disk_alarms ? { for id in var.instance_ids : id => id } : {}
  
  alarm_name          = "disk-utilization-${each.value}"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.disk_alarm_evaluation_periods
  metric_name         = "disk_used_percent"
  namespace           = "CWAgent"
  period              = var.disk_alarm_period
  statistic           = "Average"
  threshold           = var.disk_alarm_threshold
  alarm_description   = "Disk utilization is too high"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions
  
  dimensions = {
    InstanceId = each.value
  }
  
  tags = merge(
    var.alarm_tags,
    {
      Name        = "disk-utilization-${each.value}"
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
  
  name = var.sns_topic_name
  tags = merge(
    var.sns_topic_tags,
    {
      Name        = var.sns_topic_name
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
  cloudwatch_agent_config = var.create_cloudwatch_agent_config ? {
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            {
              file_path = "/var/log/messages"
              log_group_name = "/aws/ec2/${var.environment}/system"
              log_stream_name = "{instance_id}"
              timezone = "UTC"
            },
            {
              file_path = "/var/log/secure"
              log_group_name = "/aws/ec2/${var.environment}/security"
              log_stream_name = "{instance_id}"
              timezone = "UTC"
            },
            {
              file_path = "/var/log/application.log"
              log_group_name = "/aws/ec2/${var.environment}/application"
              log_stream_name = "{instance_id}"
              timezone = "UTC"
            }
          ]
        }
      }
    }
    metrics = {
      metrics_collected = {
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
    }
  } : null
}

# CloudWatch Agent Configuration File
resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  count = var.create_cloudwatch_agent_config ? 1 : 0
  
  name  = "/cloudwatch-agent/config"
  type  = "String"
  value = jsonencode(local.cloudwatch_agent_config)
  
  tags = {
    Name        = "/cloudwatch-agent/config"
    Purpose     = "CloudWatch Agent Configuration"
    ManagedBy   = "terraform"
  }
}