# Monitoring Module Variables

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "instance_ids" {
  description = "List of EC2 instance IDs to monitor"
  type        = list(string)
  default     = []
}

# CloudWatch Agent IAM Role
variable "create_cloudwatch_agent_role" {
  description = "Whether to create CloudWatch agent IAM role"
  type        = bool
  default     = true
}

variable "cloudwatch_agent_role_name" {
  description = "Name for the CloudWatch agent IAM role"
  type        = string
  default     = "cloudwatch-agent-role"
}

variable "cloudwatch_agent_role_path" {
  description = "Path for the CloudWatch agent IAM role"
  type        = string
  default     = "/"
}

variable "cloudwatch_agent_role_description" {
  description = "Description for the CloudWatch agent IAM role"
  type        = string
  default     = "IAM role for CloudWatch agent on EC2 instances"
}

variable "cloudwatch_agent_role_tags" {
  description = "Tags for the CloudWatch agent IAM role"
  type        = map(string)
  default     = {}
}

variable "cloudwatch_agent_policies" {
  description = "Map of policy ARNs to attach to CloudWatch agent role"
  type        = map(string)
  default = {
    CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    CloudWatchLogsFullAccess    = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  }
}

# CloudWatch Dashboard
variable "create_dashboard" {
  description = "Whether to create CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "dashboard_name" {
  description = "Name for the CloudWatch dashboard"
  type        = string
  default     = "ec2-monitoring-dashboard"
}

# CloudWatch Alarms
variable "create_cpu_alarms" {
  description = "Whether to create CPU utilization alarms"
  type        = bool
  default     = true
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for alarms"
  type        = number
  default     = 80
}

variable "cpu_alarm_period" {
  description = "CPU alarm evaluation period in seconds"
  type        = number
  default     = 300
}

variable "cpu_alarm_evaluation_periods" {
  description = "Number of evaluation periods for CPU alarm"
  type        = number
  default     = 2
}

variable "create_memory_alarms" {
  description = "Whether to create memory utilization alarms"
  type        = bool
  default     = true
}

variable "memory_alarm_threshold" {
  description = "Memory utilization threshold for alarms"
  type        = number
  default     = 85
}

variable "memory_alarm_period" {
  description = "Memory alarm evaluation period in seconds"
  type        = number
  default     = 300
}

variable "memory_alarm_evaluation_periods" {
  description = "Number of evaluation periods for memory alarm"
  type        = number
  default     = 2
}

variable "create_disk_alarms" {
  description = "Whether to create disk utilization alarms"
  type        = bool
  default     = true
}

variable "disk_alarm_threshold" {
  description = "Disk utilization threshold for alarms"
  type        = number
  default     = 90
}

variable "disk_alarm_period" {
  description = "Disk alarm evaluation period in seconds"
  type        = number
  default     = 300
}

variable "disk_alarm_evaluation_periods" {
  description = "Number of evaluation periods for disk alarm"
  type        = number
  default     = 2
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm triggers"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when alarm returns to OK state"
  type        = list(string)
  default     = []
}

variable "alarm_tags" {
  description = "Tags for CloudWatch alarms"
  type        = map(string)
  default     = {}
}

# CloudWatch Log Groups
variable "create_log_groups" {
  description = "Whether to create CloudWatch log groups"
  type        = bool
  default     = true
}

variable "log_groups" {
  description = "Map of log group configurations"
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
      tags = {
        Purpose = "System Logs"
      }
    }
    application = {
      name              = "/aws/ec2/application"
      retention_in_days = 30
      tags = {
        Purpose = "Application Logs"
      }
    }
    security = {
      name              = "/aws/ec2/security"
      retention_in_days = 90
      tags = {
        Purpose = "Security Logs"
      }
    }
  }
}

# SNS Topic
variable "create_sns_topic" {
  description = "Whether to create SNS topic for alarm notifications"
  type        = bool
  default     = false
}

variable "sns_topic_name" {
  description = "Name for the SNS topic"
  type        = string
  default     = "ec2-alarm-notifications"
}

variable "sns_topic_tags" {
  description = "Tags for the SNS topic"
  type        = map(string)
  default     = {}
}

variable "sns_subscriptions" {
  description = "Map of SNS topic subscriptions"
  type = map(object({
    protocol      = string
    endpoint      = string
    filter_policy = optional(string)
  }))
  default = {}
}

# CloudWatch Agent Configuration
variable "create_cloudwatch_agent_config" {
  description = "Whether to create CloudWatch agent configuration"
  type        = bool
  default     = true
}