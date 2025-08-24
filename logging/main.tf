# =============================================================================
# CLOUDWATCH LOGS CONFIGURATION
# =============================================================================

# CloudWatch Log Groups for different log types
resource "aws_cloudwatch_log_group" "application_logs" {
  for_each = var.create_cloudwatch_log_groups ? var.cloudwatch_log_groups : {}
  
  name              = each.value.name
  retention_in_days = each.value.retention_in_days
  kms_key_id        = each.value.kms_key_id
  
  tags = merge(
    each.value.tags,
    {
      Name        = each.value.name
      Purpose     = "Application Logs"
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "logging"
    }
  )
}

# =============================================================================
# S3 LOGGING CONFIGURATION
# =============================================================================

# Data source for existing S3 bucket
data "aws_s3_bucket" "existing_logging_bucket" {
  count = var.use_existing_s3_bucket ? 1 : 0
  bucket = var.existing_s3_bucket_name
}

# S3 bucket for centralized logging
resource "aws_s3_bucket" "logging_bucket" {
  count = var.create_s3_logging_bucket ? 1 : 0
  
  bucket = var.s3_logging_bucket_use_name_prefix ? null : var.s3_logging_bucket_name
  bucket_prefix = var.s3_logging_bucket_use_name_prefix ? var.s3_logging_bucket_name_prefix : null
  
  tags = merge(
    var.s3_logging_bucket_tags,
    {
      Name        = var.s3_logging_bucket_use_name_prefix ? null : var.s3_logging_bucket_name
      Purpose     = "Centralized Logging"
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "logging"
    }
  )
}

# S3 bucket versioning
resource "aws_s3_bucket_versioning" "logging_bucket" {
  count = var.create_s3_logging_bucket ? 1 : 0
  
  bucket = aws_s3_bucket.logging_bucket[0].id
  
  versioning_configuration {
    status = var.s3_logging_bucket_versioning ? "Enabled" : "Disabled"
  }
}

# S3 bucket encryption
resource "aws_s3_bucket_server_side_encryption_configuration" "logging_bucket" {
  count = var.create_s3_logging_bucket ? 1 : 0
  
  bucket = aws_s3_bucket.logging_bucket[0].id
  
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm     = var.s3_logging_bucket_encryption_algorithm
      kms_master_key_id = var.s3_logging_bucket_kms_key_id
    }
    bucket_key_enabled = var.s3_logging_bucket_bucket_key_enabled
  }
}

# S3 bucket lifecycle policy (for created bucket)
resource "aws_s3_bucket_lifecycle_configuration" "logging_bucket" {
  count = var.create_s3_logging_bucket && length(var.s3_logging_bucket_lifecycle_rules) > 0 ? 1 : 0
  
  bucket = aws_s3_bucket.logging_bucket[0].id
  
  dynamic "rule" {
    for_each = var.s3_logging_bucket_lifecycle_rules
    
    content {
      id     = rule.value.id
      status = rule.value.status
      
      dynamic "transition" {
        for_each = rule.value.transitions
        
        content {
          days          = transition.value.days
          storage_class = transition.value.storage_class
        }
      }
      
      dynamic "expiration" {
        for_each = rule.value.expiration != null ? [rule.value.expiration] : []
        
        content {
          days = expiration.value.days
        }
      }
      
      dynamic "noncurrent_version_transition" {
        for_each = rule.value.noncurrent_version_transitions
        
        content {
          noncurrent_days = noncurrent_version_transition.value.noncurrent_days
          storage_class   = noncurrent_version_transition.value.storage_class
        }
      }
      
      dynamic "noncurrent_version_expiration" {
        for_each = rule.value.noncurrent_version_expiration != null ? [rule.value.noncurrent_version_expiration] : []
        
        content {
          noncurrent_days = noncurrent_version_expiration.value.noncurrent_days
        }
      }
    }
  }
}

# S3 bucket public access block
resource "aws_s3_bucket_public_access_block" "logging_bucket" {
  count = var.create_s3_logging_bucket ? 1 : 0
  
  bucket = aws_s3_bucket.logging_bucket[0].id
  
  block_public_acls       = var.s3_logging_bucket_block_public_access
  block_public_policy     = var.s3_logging_bucket_block_public_access
  ignore_public_acls      = var.s3_logging_bucket_block_public_access
  restrict_public_buckets = var.s3_logging_bucket_block_public_access
}

# =============================================================================
# LOGGING IAM ROLE AND POLICIES
# =============================================================================

# IAM role for logging services
resource "aws_iam_role" "logging_role" {
  count = var.create_logging_iam_role ? 1 : 0
  
  name = var.logging_iam_role_use_name_prefix ? null : var.logging_iam_role_name
  name_prefix = var.logging_iam_role_use_name_prefix ? var.logging_iam_role_name_prefix : null
  path = var.logging_iam_role_path
  description = var.logging_iam_role_description
  
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
    var.logging_iam_role_tags,
    {
      Name        = var.logging_iam_role_use_name_prefix ? null : var.logging_iam_role_name
      Purpose     = "Logging Services"
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "logging"
    }
  )
}

# IAM instance profile for logging
resource "aws_iam_instance_profile" "logging_profile" {
  count = var.create_logging_iam_role ? 1 : 0
  
  name = var.logging_instance_profile_use_name_prefix ? null : (
    var.logging_instance_profile_name != null ? var.logging_instance_profile_name : "${var.logging_iam_role_name}-profile"
  )
  name_prefix = var.logging_instance_profile_use_name_prefix ? var.logging_instance_profile_name_prefix : null
  path = var.logging_instance_profile_path
  role = aws_iam_role.logging_role[0].name
  
  tags = merge(
    var.logging_instance_profile_tags,
    {
      Name        = var.logging_instance_profile_use_name_prefix ? null : (
        var.logging_instance_profile_name != null ? var.logging_instance_profile_name : "${var.logging_iam_role_name}-profile"
      )
      Purpose     = "Logging Instance Profile"
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "logging"
    }
  )
}

# Attach logging policies to IAM role
resource "aws_iam_role_policy_attachment" "logging_policies" {
  for_each = var.create_logging_iam_role ? var.logging_iam_role_policies : {}
  
  role       = aws_iam_role.logging_role[0].name
  policy_arn = each.value
}

# Custom policy for S3 logging access
resource "aws_iam_role_policy" "s3_logging_access" {
  count = var.create_logging_iam_role && (var.create_s3_logging_bucket || var.use_existing_s3_bucket) ? 1 : 0
  
  name = "s3-logging-access"
  role = aws_iam_role.logging_role[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          local.s3_bucket_arn,
          "${local.s3_bucket_arn}/*"
        ]
      }
    ]
  })
}

# Custom policy for CloudWatch Logs access
resource "aws_iam_role_policy" "cloudwatch_logs_access" {
  count = var.create_logging_iam_role ? 1 : 0
  
  name = "cloudwatch-logs-access"
  role = aws_iam_role.logging_role[0].id
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ]
        Resource = "*"
      }
    ]
  })
}

# =============================================================================
# LOGGING AGENT CONFIGURATION
# =============================================================================

# SSM Parameter for logging agent configuration
resource "aws_ssm_parameter" "logging_agent_config" {
  count = var.create_logging_agent_config ? 1 : 0
  
  name = var.logging_agent_config_parameter_use_name_prefix ? null : var.logging_agent_config_parameter_name
  name_prefix = var.logging_agent_config_parameter_use_name_prefix ? var.logging_agent_config_parameter_name_prefix : null
  type  = "String"
  value = jsonencode(local.logging_agent_configuration)
  
  tags = merge(
    var.logging_agent_config_parameter_tags,
    {
      Name        = var.logging_agent_config_parameter_use_name_prefix ? null : var.logging_agent_config_parameter_name
      Purpose     = "Logging Agent Configuration"
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "logging"
    }
  )
}

# Local configuration for logging agent
locals {
  # Determine which S3 bucket to use
  s3_bucket_arn = var.use_existing_s3_bucket ? (
    var.existing_s3_bucket_arn != null ? var.existing_s3_bucket_arn : data.aws_s3_bucket.existing_logging_bucket[0].arn
  ) : (
    var.create_s3_logging_bucket ? aws_s3_bucket.logging_bucket[0].arn : null
  )
  
  s3_bucket_name = var.use_existing_s3_bucket ? (
    var.existing_s3_bucket_name != null ? var.existing_s3_bucket_name : data.aws_s3_bucket.existing_logging_bucket[0].bucket
  ) : (
    var.create_s3_logging_bucket ? aws_s3_bucket.logging_bucket[0].bucket : null
  )
  
  default_log_configs = {
    system = {
      file_path = "/var/log/syslog"
      log_group_name = "/aws/ec2/${var.environment}/system"
      log_stream_name = "{instance_id}"
      timezone = "UTC"
      tags = {
        LogType = "system"
        Environment = var.environment
      }
    }
    auth = {
      file_path = "/var/log/auth.log"
      log_group_name = "/aws/ec2/${var.environment}/auth"
      log_stream_name = "{instance_id}"
      timezone = "UTC"
      tags = {
        LogType = "auth"
        Environment = var.environment
      }
    }
    application = {
      file_path = "/var/log/application.log"
      log_group_name = "/aws/ec2/${var.environment}/application"
      log_stream_name = "{instance_id}"
      timezone = "UTC"
      tags = {
        LogType = "application"
        Environment = var.environment
      }
    }
  }
  
  custom_log_configs = length(var.logging_agent_config_logs) > 0 ? var.logging_agent_config_logs : local.default_log_configs
  
  logging_agent_configuration = var.create_logging_agent_config ? {
    logs = {
      logs_collected = {
        files = {
          collect_list = [
            for name, config in local.custom_log_configs : {
              file_path = config.file_path
              log_group_name = config.log_group_name
              log_stream_name = config.log_stream_name
              timezone = config.timezone
              timestamp_format = config.timestamp_format
              multi_line_start_pattern = config.multi_line_start_pattern
              encoding = config.encoding
              buffer_duration = config.buffer_duration
              batch_count = config.batch_count
              batch_size = config.batch_size
            }
          }
        }
      }
    }
    s3 = (var.create_s3_logging_bucket || var.use_existing_s3_bucket) ? {
      bucket_name = local.s3_bucket_name
      region = var.aws_region
      upload_frequency = var.s3_logging_upload_frequency
      compression = var.s3_logging_compression
    } : null
  } : null
}

# =============================================================================
# LOGGING ALARMS AND NOTIFICATIONS
# =============================================================================

# CloudWatch Alarms for logging
resource "aws_cloudwatch_metric_alarm" "log_errors" {
  for_each = var.create_logging_alarms ? { for id in var.instance_ids : id => id } : {}
  
  alarm_name = var.logging_alarm_use_name_prefix ? null : (
    var.logging_alarm_name != null ? "${var.logging_alarm_name}-${each.value}" : "log-errors-${each.value}"
  )
  alarm_name_prefix = var.logging_alarm_use_name_prefix ? var.logging_alarm_name_prefix : null
  alarm_description = var.logging_alarm_description
  
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = var.logging_alarm_evaluation_periods
  metric_name         = "LogErrorCount"
  namespace           = "AWS/Logs"
  period              = var.logging_alarm_period
  statistic           = "Sum"
  threshold           = var.logging_alarm_threshold
  treat_missing_data  = "notBreaching"
  
  dimensions = {
    InstanceId = each.value
  }
  
  alarm_actions = var.logging_alarm_actions
  ok_actions    = var.logging_ok_actions
  
  tags = merge(
    var.logging_alarm_tags,
    {
      Name        = var.logging_alarm_use_name_prefix ? null : (
        var.logging_alarm_name != null ? "${var.logging_alarm_name}-${each.value}" : "log-errors-${each.value}"
      )
      InstanceId  = each.value
      Metric      = "LogErrorCount"
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "logging"
    }
  )
}

# SNS Topic for logging notifications
resource "aws_sns_topic" "logging_notifications" {
  count = var.create_logging_sns_topic ? 1 : 0
  
  name = var.logging_sns_topic_use_name_prefix ? null : var.logging_sns_topic_name
  name_prefix = var.logging_sns_topic_use_name_prefix ? var.logging_sns_topic_name_prefix : null
  
  tags = merge(
    var.logging_sns_topic_tags,
    {
      Name        = var.logging_sns_topic_use_name_prefix ? null : var.logging_sns_topic_name
      Purpose     = "Logging Notifications"
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "logging"
    }
  )
}

# SNS Topic Subscriptions
resource "aws_sns_topic_subscription" "logging_notifications" {
  for_each = var.create_logging_sns_topic ? var.logging_sns_subscriptions : {}
  
  topic_arn = aws_sns_topic.logging_notifications[0].arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
  filter_policy = each.value.filter_policy
  
  tags = merge(
    var.logging_sns_subscription_tags,
    each.value.tags,
    {
      Purpose     = "Logging SNS Subscription"
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "logging"
    }
  )
}

# =============================================================================
# LOGGING DASHBOARD
# =============================================================================

# CloudWatch Dashboard for logging
resource "aws_cloudwatch_dashboard" "logging_dashboard" {
  count = var.create_logging_dashboard ? 1 : 0
  
  dashboard_name = var.logging_dashboard_use_name_prefix ? null : var.logging_dashboard_name
  dashboard_name_prefix = var.logging_dashboard_use_name_prefix ? var.logging_dashboard_name_prefix : null
  
  dashboard_body = jsonencode({
    widgets = [
      {
        type = "metric"
        x    = 0
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            for id in var.instance_ids : [
              "AWS/Logs",
              "LogErrorCount",
              "InstanceId",
              id
            ]
          ]
          period = 300
          stat   = "Sum"
          region = var.aws_region
          title  = "Log Errors by Instance"
        }
      },
      {
        type = "metric"
        x    = 12
        y    = 0
        width = 12
        height = 6
        properties = {
          metrics = [
            for id in var.instance_ids : [
              "AWS/Logs",
              "LogStreamCount",
              "InstanceId",
              id
            ]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "Log Streams by Instance"
        }
      }
    ]
  })
  
  tags = merge(
    var.logging_dashboard_tags,
    {
      Name        = var.logging_dashboard_use_name_prefix ? null : var.logging_dashboard_name
      Purpose     = "Logging Dashboard"
      Environment = var.environment
      ManagedBy   = "terraform"
      Module      = "logging"
    }
  )
}