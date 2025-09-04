# Multi-Monitoring Example Variables

variable "aws_region" {
  description = "AWS region for all resources"
  type        = string
  default     = "us-west-2"
}

variable "sns_topic_arn" {
  description = "SNS topic ARN for CloudWatch alarms (optional)"
  type        = string
  default     = ""
}

variable "vpc_id" {
  description = "VPC ID where the EC2 instances will be created"
  type        = string
}

variable "allowed_cidr_blocks" {
  description = "CIDR blocks allowed to SSH to the instances"
  type        = list(string)
  default     = ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"]
}

# Server-specific overrides (optional)
variable "server_overrides" {
  description = "Override specific server configurations"
  type = map(object({
    instance_type = optional(string)
    environment  = optional(string)
    project      = optional(string)
    monitoring   = optional(string)
    
    # Monitoring profile overrides
    cpu_threshold = optional(number)
    memory_threshold = optional(number)
    disk_threshold = optional(number)
    
    # Custom alarm overrides
    custom_alarm_thresholds = optional(map(number))
    
    # Resource creation overrides
    create_dashboard = optional(bool)
    create_log_group = optional(bool)
    create_cpu_alarm = optional(bool)
    create_memory_alarm = optional(bool)
  }))
  default = {}
}

# Environment-specific configurations
variable "environment_configs" {
  description = "Environment-specific monitoring configurations"
  type = map(object({
    monitoring_level = string
    alarm_actions = list(string)
    ok_actions = list(string)
    log_retention_days = number
    dashboard_period = number
  }))
  default = {
    production = {
      monitoring_level = "enhanced"
      alarm_actions = []
      ok_actions = []
      log_retention_days = 90
      dashboard_period = 300
    }
    staging = {
      monitoring_level = "standard"
      alarm_actions = []
      ok_actions = []
      log_retention_days = 60
      dashboard_period = 300
    }
    development = {
      monitoring_level = "minimal"
      alarm_actions = []
      ok_actions = []
      log_retention_days = 30
      dashboard_period = 600
    }
  }
}