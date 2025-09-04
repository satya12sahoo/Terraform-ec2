# EC2 Monitoring Module - CloudWatch Agent Installation and Configuration
# This module provides comprehensive monitoring for EC2 instances using CloudWatch agent

# Local values for default configurations
locals {
  # Default naming convention: {ec2_instance_name}-{resource_type}
  default_iam_role_name           = "${var.ec2_instance_name}-CloudWatchAgentRole"
  default_iam_policy_name         = "${var.ec2_instance_name}-CloudWatchAgentPolicy"
  default_iam_instance_profile_name = "${var.ec2_instance_name}-CloudWatchAgentProfile"
  default_ssm_parameter_name      = "/cloudwatch-agent/${var.ec2_instance_name}/config"
  default_dashboard_name          = "${var.ec2_instance_name}-Monitoring-Dashboard"
  default_log_group_name          = "/aws/ec2/${var.ec2_instance_name}/logs"
  
  # Profile-based configurations
  profile_config = var.monitoring_profiles.profile == "web_server" ? var.monitoring_profiles.web_server : 
                  var.monitoring_profiles.profile == "database_server" ? var.monitoring_profiles.database_server :
                  var.monitoring_profiles.profile == "application_server" ? var.monitoring_profiles.application_server :
                  null
  
  # Default dashboard configuration
  default_dashboard_config = {
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/EC2", "CPUUtilization", "InstanceId", var.ec2_instance_name],
            [".", "NetworkIn", ".", "."],
            [".", "NetworkOut", ".", "."]
          ]
          period = var.dashboard_period
          stat   = var.dashboard_stat
          region = var.aws_region
          title  = "EC2 Instance Metrics"
          view   = "timeSeries"
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
            ["CWAgent", "mem_used_percent", "InstanceId", var.ec2_instance_name],
            [".", "disk_used_percent", ".", "."]
          ]
          period = var.dashboard_period
          stat   = var.dashboard_stat
          region = var.aws_region
          title  = "System Metrics (CloudWatch Agent)"
          view   = "timeSeries"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 6
        width  = 24
        height = 6
        properties = {
          metrics = [
            ["CWAgent", "cpu_usage_idle", "InstanceId", var.ec2_instance_name],
            [".", "cpu_usage_user", ".", "."],
            [".", "cpu_usage_system", ".", "."]
          ]
          period = var.dashboard_period
          stat   = var.dashboard_stat
          region = var.aws_region
          title  = "CPU Usage Breakdown"
          view   = "timeSeries"
          stacked = true
        }
      }
    ]
  }
  
  # Use custom dashboard config if provided, otherwise use default
  dashboard_body = var.dashboard_config != null ? jsonencode(var.dashboard_config) : jsonencode(local.default_dashboard_config)
}

# CloudWatch Agent IAM Role
resource "aws_iam_role" "cloudwatch_agent_role" {
  count = var.create_iam_role ? 1 : 0
  
  name = coalesce(var.iam_role_name, local.default_iam_role_name)
  path = var.iam_role_path

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = var.tags
}

# CloudWatch Agent IAM Policy
resource "aws_iam_policy" "cloudwatch_agent_policy" {
  count = var.create_iam_role ? 1 : 0
  
  name        = coalesce(var.iam_policy_name, local.default_iam_policy_name)
  description = "Policy for CloudWatch agent to send metrics and logs"
  path        = var.iam_policy_path

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "cloudwatch:PutMetricData",
          "ec2:DescribeVolumes",
          "ec2:DescribeTags",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams",
          "logs:DescribeLogGroups",
          "logs:CreateLogStream",
          "logs:CreateLogGroup"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter"
        ]
        Resource = "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
      }
    ]
  })

  tags = var.tags
}

# Attach policy to role
resource "aws_iam_role_policy_attachment" "cloudwatch_agent_policy_attachment" {
  count = var.create_iam_role ? 1 : 0
  
  role       = aws_iam_role.cloudwatch_agent_role[0].name
  policy_arn = aws_iam_policy.cloudwatch_agent_policy[0].arn
}

# CloudWatch Agent IAM Instance Profile
resource "aws_iam_instance_profile" "cloudwatch_agent_profile" {
  count = var.create_iam_role ? 1 : 0
  
  name = coalesce(var.iam_instance_profile_name, local.default_iam_instance_profile_name)
  role = aws_iam_role.cloudwatch_agent_role[0].name

  tags = var.tags
}

# CloudWatch Agent Configuration
resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  count = var.create_ssm_parameter ? 1 : 0
  
  name        = coalesce(var.ssm_parameter_name, local.default_ssm_parameter_name)
  description = "CloudWatch agent configuration for EC2 instances"
  type        = "String"
  value       = var.cloudwatch_agent_config
  tier        = var.ssm_parameter_tier

  tags = var.tags
}

# CloudWatch Dashboard for EC2 Monitoring
resource "aws_cloudwatch_dashboard" "ec2_monitoring_dashboard" {
  count = var.create_dashboard ? 1 : 0
  
  dashboard_name = coalesce(var.dashboard_name, local.default_dashboard_name)

  dashboard_body = local.dashboard_body

  tags = var.tags
}

# CloudWatch Log Group for EC2 logs
resource "aws_cloudwatch_log_group" "ec2_logs" {
  count = var.create_log_group ? 1 : 0
  
  name              = coalesce(var.log_group_name, local.default_log_group_name)
  retention_in_days = var.log_retention_days

  tags = var.tags
}

# CloudWatch Alarm for High CPU
resource "aws_cloudwatch_metric_alarm" "high_cpu_alarm" {
  count = var.create_cpu_alarm ? 1 : 0
  
  alarm_name          = "${var.ec2_instance_name}-high-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.cpu_alarm_evaluation_periods
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = var.cpu_alarm_period
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "This metric monitors EC2 CPU utilization"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    InstanceId = var.ec2_instance_name
  }

  tags = var.tags
}

# CloudWatch Alarm for High Memory
resource "aws_cloudwatch_metric_alarm" "high_memory_alarm" {
  count = var.create_memory_alarm ? 1 : 0
  
  alarm_name          = "${var.ec2_instance_name}-high-memory"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.memory_alarm_evaluation_periods
  metric_name         = "mem_used_percent"
  namespace           = "CWAgent"
  period              = var.memory_alarm_period
  statistic           = "Average"
  threshold           = var.memory_alarm_threshold
  alarm_description   = "This metric monitors EC2 memory utilization via CloudWatch agent"
  alarm_actions       = var.alarm_actions
  ok_actions          = var.ok_actions

  dimensions = {
    InstanceId = var.ec2_instance_name
  }

  tags = var.tags
}

# Custom CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "custom_alarms" {
  for_each = { for idx, alarm in var.custom_alarms : alarm.name => alarm }
  
  alarm_name          = "${var.ec2_instance_name}-${each.value.name}"
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  threshold           = each.value.threshold
  alarm_description   = each.value.description
  alarm_actions       = each.value.alarm_actions
  ok_actions          = each.value.ok_actions
  insufficient_data_actions = each.value.insufficient_data_actions
  treat_missing_data  = each.value.treat_missing_data
  datapoints_to_alarm = each.value.datapoints_to_alarm
  extended_statistic  = each.value.extended_statistic
  unit                = each.value.unit

  dynamic "dimensions" {
    for_each = each.value.dimensions
    content {
      name  = dimensions.key
      value = dimensions.value
    }
  }

  tags = merge(var.tags, {
    AlarmType = "custom"
    MetricName = each.value.metric_name
  })
}