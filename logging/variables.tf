# =============================================================================
# BASIC CONFIGURATION
# =============================================================================

variable "aws_region" {
  description = "AWS region where logging resources will be created"
  type        = string
}

variable "environment" {
  description = "Environment name for tagging and naming"
  type        = string
}

variable "instance_ids" {
  description = "List of EC2 instance IDs to monitor for logging"
  type        = list(string)
  default     = []
}

# =============================================================================
# CLOUDWATCH LOGS CONFIGURATION
# =============================================================================

variable "create_cloudwatch_log_groups" {
  description = "Whether to create CloudWatch log groups"
  type        = bool
  default     = true
}

variable "cloudwatch_log_groups" {
  description = "Map of CloudWatch log groups to create"
  type = map(object({
    name              = string
    retention_in_days = number
    kms_key_id        = optional(string)
    tags              = optional(map(string), {})
  }))
  default = {
    system = {
      name              = "/aws/ec2/system"
      retention_in_days = 30
    }
    auth = {
      name              = "/aws/ec2/auth"
      retention_in_days = 30
    }
    application = {
      name              = "/aws/ec2/application"
      retention_in_days = 30
    }
  }
}

# =============================================================================
# S3 LOGGING CONFIGURATION
# =============================================================================

variable "create_s3_logging_bucket" {
  description = "Whether to create S3 bucket for centralized logging"
  type        = bool
  default     = false
}

variable "use_existing_s3_bucket" {
  description = "Whether to use an existing S3 bucket for logging"
  type        = bool
  default     = false
}

variable "existing_s3_bucket_name" {
  description = "Name of existing S3 bucket to use for logging"
  type        = string
  default     = null
}

variable "existing_s3_bucket_arn" {
  description = "ARN of existing S3 bucket to use for logging"
  type        = string
  default     = null
}

variable "s3_logging_bucket_name" {
  description = "Name of the S3 logging bucket (only used if create_s3_logging_bucket = true)"
  type        = string
  default     = null
}

variable "s3_logging_bucket_name_prefix" {
  description = "Name prefix for the S3 logging bucket"
  type        = string
  default     = "logging-bucket-"
}

variable "s3_logging_bucket_use_name_prefix" {
  description = "Whether to use name prefix for S3 logging bucket"
  type        = bool
  default     = true
}

variable "s3_logging_bucket_tags" {
  description = "Tags for the S3 logging bucket"
  type        = map(string)
  default     = {}
}

variable "s3_logging_bucket_versioning" {
  description = "Whether to enable versioning on the S3 logging bucket"
  type        = bool
  default     = true
}

variable "s3_logging_bucket_encryption_algorithm" {
  description = "Encryption algorithm for S3 logging bucket"
  type        = string
  default     = "AES256"
}

variable "s3_logging_bucket_kms_key_id" {
  description = "KMS key ID for S3 logging bucket encryption"
  type        = string
  default     = null
}

variable "s3_logging_bucket_bucket_key_enabled" {
  description = "Whether to enable bucket key for S3 logging bucket"
  type        = bool
  default     = true
}

variable "s3_logging_bucket_block_public_access" {
  description = "Whether to block public access to S3 logging bucket"
  type        = bool
  default     = true
}

variable "s3_logging_bucket_lifecycle_rules" {
  description = "Lifecycle rules for S3 logging bucket"
  type = list(object({
    id = string
    status = string
    transitions = optional(list(object({
      days          = number
      storage_class = string
    })), [])
    expiration = optional(object({
      days = number
    }), null)
    noncurrent_version_transitions = optional(list(object({
      noncurrent_days = number
      storage_class   = string
    })), [])
    noncurrent_version_expiration = optional(object({
      noncurrent_days = number
    }), null)
  }))
  default = [
    {
      id     = "log-retention"
      status = "Enabled"
      expiration = {
        days = 365
      }
    }
  ]
}

variable "s3_logging_upload_frequency" {
  description = "Upload frequency for S3 logging"
  type        = string
  default     = "5m"
}

variable "s3_logging_compression" {
  description = "Compression type for S3 logging"
  type        = string
  default     = "gzip"
}

# =============================================================================
# LOGGING IAM ROLE CONFIGURATION
# =============================================================================

variable "create_logging_iam_role" {
  description = "Whether to create IAM role for logging services"
  type        = bool
  default     = true
}

variable "logging_iam_role_name" {
  description = "Name of the logging IAM role"
  type        = string
  default     = "ec2-logging-role"
}

variable "logging_iam_role_name_prefix" {
  description = "Name prefix for the logging IAM role"
  type        = string
  default     = "logging-role-"
}

variable "logging_iam_role_use_name_prefix" {
  description = "Whether to use name prefix for logging IAM role"
  type        = bool
  default     = false
}

variable "logging_iam_role_path" {
  description = "Path for the logging IAM role"
  type        = string
  default     = "/"
}

variable "logging_iam_role_description" {
  description = "Description for the logging IAM role"
  type        = string
  default     = "IAM role for EC2 logging services"
}

variable "logging_iam_role_tags" {
  description = "Tags for the logging IAM role"
  type        = map(string)
  default     = {}
}

variable "logging_iam_role_policies" {
  description = "Map of IAM policy ARNs to attach to logging role"
  type        = map(string)
  default = {
    CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    CloudWatchLogsFullAccess    = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  }
}

# =============================================================================
# LOGGING INSTANCE PROFILE CONFIGURATION
# =============================================================================

variable "logging_instance_profile_name" {
  description = "Name of the logging instance profile"
  type        = string
  default     = null
}

variable "logging_instance_profile_name_prefix" {
  description = "Name prefix for the logging instance profile"
  type        = string
  default     = "logging-profile-"
}

variable "logging_instance_profile_use_name_prefix" {
  description = "Whether to use name prefix for logging instance profile"
  type        = bool
  default     = false
}

variable "logging_instance_profile_path" {
  description = "Path for the logging instance profile"
  type        = string
  default     = "/"
}

variable "logging_instance_profile_tags" {
  description = "Tags for the logging instance profile"
  type        = map(string)
  default     = {}
}

# =============================================================================
# LOGGING AGENT CONFIGURATION
# =============================================================================

variable "create_logging_agent_config" {
  description = "Whether to create logging agent configuration"
  type        = bool
  default     = true
}

variable "logging_agent_config_parameter_name" {
  description = "Name of the logging agent configuration parameter"
  type        = string
  default     = "/ec2/logging/agent-config"
}

variable "logging_agent_config_parameter_name_prefix" {
  description = "Name prefix for the logging agent configuration parameter"
  type        = string
  default     = "logging-config-"
}

variable "logging_agent_config_parameter_use_name_prefix" {
  description = "Whether to use name prefix for logging agent configuration parameter"
  type        = bool
  default     = false
}

variable "logging_agent_config_parameter_tags" {
  description = "Tags for the logging agent configuration parameter"
  type        = map(string)
  default     = {}
}

variable "logging_agent_config_logs" {
  description = "Custom log configurations for the logging agent"
  type = map(object({
    file_path = string
    log_group_name = string
    log_stream_name = string
    timezone = optional(string, "UTC")
    timestamp_format = optional(string)
    multi_line_start_pattern = optional(string)
    encoding = optional(string, "utf-8")
    buffer_duration = optional(string, "5000")
    batch_count = optional(number, 1000)
    batch_size = optional(number, 32768)
    tags = optional(map(string), {})
  }))
  default = {}
}

# =============================================================================
# LOGGING ALARMS CONFIGURATION
# =============================================================================

variable "create_logging_alarms" {
  description = "Whether to create CloudWatch alarms for logging"
  type        = bool
  default     = true
}

variable "logging_alarm_name" {
  description = "Name for logging alarms"
  type        = string
  default     = null
}

variable "logging_alarm_name_prefix" {
  description = "Name prefix for logging alarms"
  type        = string
  default     = "logging-alarm-"
}

variable "logging_alarm_use_name_prefix" {
  description = "Whether to use name prefix for logging alarms"
  type        = bool
  default     = false
}

variable "logging_alarm_description" {
  description = "Description for logging alarms"
  type        = string
  default     = "Log error count alarm"
}

variable "logging_alarm_threshold" {
  description = "Threshold for logging alarms"
  type        = number
  default     = 10
}

variable "logging_alarm_period" {
  description = "Period for logging alarms"
  type        = number
  default     = 300
}

variable "logging_alarm_evaluation_periods" {
  description = "Evaluation periods for logging alarms"
  type        = number
  default     = 2
}

variable "logging_alarm_actions" {
  description = "Actions to take when logging alarm triggers"
  type        = list(string)
  default     = []
}

variable "logging_ok_actions" {
  description = "Actions to take when logging alarm returns to OK state"
  type        = list(string)
  default     = []
}

variable "logging_alarm_tags" {
  description = "Tags for logging alarms"
  type        = map(string)
  default     = {}
}

# =============================================================================
# LOGGING SNS CONFIGURATION
# =============================================================================

variable "create_logging_sns_topic" {
  description = "Whether to create SNS topic for logging notifications"
  type        = bool
  default     = false
}

variable "logging_sns_topic_name" {
  description = "Name of the logging SNS topic"
  type        = string
  default     = "ec2-logging-notifications"
}

variable "logging_sns_topic_name_prefix" {
  description = "Name prefix for the logging SNS topic"
  type        = string
  default     = "logging-topic-"
}

variable "logging_sns_topic_use_name_prefix" {
  description = "Whether to use name prefix for logging SNS topic"
  type        = bool
  default     = false
}

variable "logging_sns_topic_tags" {
  description = "Tags for the logging SNS topic"
  type        = map(string)
  default     = {}
}

variable "logging_sns_subscriptions" {
  description = "Map of SNS subscriptions for logging notifications"
  type = map(object({
    protocol = string
    endpoint = string
    filter_policy = optional(string)
    tags = optional(map(string), {})
  }))
  default = {}
}

variable "logging_sns_subscription_tags" {
  description = "Tags for logging SNS subscriptions"
  type        = map(string)
  default     = {}
}

# =============================================================================
# LOGGING DASHBOARD CONFIGURATION
# =============================================================================

variable "create_logging_dashboard" {
  description = "Whether to create CloudWatch dashboard for logging"
  type        = bool
  default     = true
}

variable "logging_dashboard_name" {
  description = "Name of the logging dashboard"
  type        = string
  default     = "ec2-logging-dashboard"
}

variable "logging_dashboard_name_prefix" {
  description = "Name prefix for the logging dashboard"
  type        = string
  default     = "logging-dashboard-"
}

variable "logging_dashboard_use_name_prefix" {
  description = "Whether to use name prefix for logging dashboard"
  type        = bool
  default     = false
}

variable "logging_dashboard_tags" {
  description = "Tags for the logging dashboard"
  type        = map(string)
  default     = {}
}