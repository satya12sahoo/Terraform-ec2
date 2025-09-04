# EC2 Monitoring Module - CloudWatch Agent Installation and Configuration
# This module provides comprehensive monitoring for EC2 instances using CloudWatch agent

# CloudWatch Agent IAM Role
resource "aws_iam_role" "cloudwatch_agent_role" {
  count = var.create_iam_role ? 1 : 0
  
  name = var.iam_role_name
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
  
  name        = var.iam_policy_name
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
  
  name = var.iam_instance_profile_name
  role = aws_iam_role.cloudwatch_agent_role[0].name

  tags = var.tags
}

# CloudWatch Agent Configuration
resource "aws_ssm_parameter" "cloudwatch_agent_config" {
  count = var.create_ssm_parameter ? 1 : 0
  
  name        = var.ssm_parameter_name
  description = "CloudWatch agent configuration for EC2 instances"
  type        = "String"
  value       = var.cloudwatch_agent_config
  tier        = var.ssm_parameter_tier

  tags = var.tags
}

# CloudWatch Dashboard for EC2 Monitoring
resource "aws_cloudwatch_dashboard" "ec2_monitoring_dashboard" {
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
            ["AWS/EC2", "CPUUtilization", "AutoScalingGroupName", var.ec2_instance_name],
            [".", "NetworkIn", ".", "."],
            [".", "NetworkOut", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "EC2 Instance Metrics"
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
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "System Metrics (CloudWatch Agent)"
        }
      }
    ]
  })

  tags = var.tags
}

# CloudWatch Log Group for EC2 logs
resource "aws_cloudwatch_log_group" "ec2_logs" {
  count = var.create_log_group ? 1 : 0
  
  name              = var.log_group_name
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