# EC2 Monitoring Module Variables

variable "ec2_instance_name" {
  description = "Name of the EC2 instance to monitor"
  type        = string
}

variable "aws_region" {
  description = "AWS region for the monitoring resources"
  type        = string
  default     = "us-west-2"
}

# IAM Role Configuration
variable "create_iam_role" {
  description = "Whether to create IAM role for CloudWatch agent"
  type        = bool
  default     = true
}

variable "iam_role_name" {
  description = "Name of the IAM role for CloudWatch agent"
  type        = string
  default     = null
}

variable "iam_role_path" {
  description = "Path for the IAM role"
  type        = string
  default     = "/"
}

variable "iam_policy_name" {
  description = "Name of the IAM policy for CloudWatch agent"
  type        = string
  default     = null
}

variable "iam_policy_path" {
  description = "Path for the IAM policy"
  type        = string
  default     = "/"
}

variable "iam_instance_profile_name" {
  description = "Name of the IAM instance profile"
  type        = string
  default     = null
}

# SSM Parameter Configuration
variable "create_ssm_parameter" {
  description = "Whether to create SSM parameter for CloudWatch agent configuration"
  type        = bool
  default     = true
}

variable "ssm_parameter_name" {
  description = "Name of the SSM parameter for CloudWatch agent configuration"
  type        = string
  default     = null
}

variable "ssm_parameter_tier" {
  description = "Tier for the SSM parameter"
  type        = string
  default     = "Standard"
}

variable "cloudwatch_agent_config" {
  description = "CloudWatch agent configuration JSON"
  type        = string
  default     = <<-EOT
{
  "agent": {
    "metrics_collection_interval": 60,
    "run_as_user": "root"
  },
  "logs": {
    "logs_collected": {
      "files": {
        "collect_list": [
          {
            "file_path": "/var/log/messages",
            "log_group_name": "/aws/ec2/var/log/messages",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          },
          {
            "file_path": "/var/log/secure",
            "log_group_name": "/aws/ec2/var/log/secure",
            "log_stream_name": "{instance_id}",
            "timezone": "UTC"
          }
        ]
      }
    }
  },
  "metrics": {
    "metrics_collected": {
      "cpu": {
        "measurement": [
          "cpu_usage_idle",
          "cpu_usage_iowait",
          "cpu_usage_user",
          "cpu_usage_system"
        ],
        "metrics_collection_interval": 60,
        "totalcpu": false
      },
      "disk": {
        "measurement": [
          "used_percent"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "diskio": {
        "measurement": [
          "io_time"
        ],
        "metrics_collection_interval": 60,
        "resources": [
          "*"
        ]
      },
      "mem": {
        "measurement": [
          "mem_used_percent"
        ],
        "metrics_collection_interval": 60
      },
      "netstat": {
        "measurement": [
          "tcp_established",
          "tcp_time_wait"
        ],
        "metrics_collection_interval": 60
      },
      "swap": {
        "measurement": [
          "swap_used_percent"
        ],
        "metrics_collection_interval": 60
      }
    }
  }
}
EOT
}

# CloudWatch Dashboard Configuration
variable "create_dashboard" {
  description = "Whether to create CloudWatch dashboard"
  type        = bool
  default     = true
}

variable "dashboard_name" {
  description = "Name of the CloudWatch dashboard"
  type        = string
  default     = null
}

# CloudWatch Log Group Configuration
variable "create_log_group" {
  description = "Whether to create CloudWatch log group"
  type        = bool
  default     = true
}

variable "log_group_name" {
  description = "Name of the CloudWatch log group"
  type        = string
  default     = null
}

variable "log_retention_days" {
  description = "Number of days to retain CloudWatch logs"
  type        = number
  default     = 30
}

# CloudWatch Alarm Configuration
variable "create_cpu_alarm" {
  description = "Whether to create CPU utilization alarm"
  type        = bool
  default     = true
}

variable "cpu_alarm_threshold" {
  description = "CPU utilization threshold for alarm (percentage)"
  type        = number
  default     = 80
}

variable "cpu_alarm_period" {
  description = "Period for CPU alarm evaluation (seconds)"
  type        = number
  default     = 300
}

variable "cpu_alarm_evaluation_periods" {
  description = "Number of evaluation periods for CPU alarm"
  type        = number
  default     = 2
}

variable "create_memory_alarm" {
  description = "Whether to create memory utilization alarm"
  type        = bool
  default     = true
}

variable "memory_alarm_threshold" {
  description = "Memory utilization threshold for alarm (percentage)"
  type        = number
  default     = 80
}

variable "memory_alarm_period" {
  description = "Period for memory alarm evaluation (seconds)"
  type        = number
  default     = 300
}

variable "memory_alarm_evaluation_periods" {
  description = "Number of evaluation periods for memory alarm"
  type        = number
  default     = 2
}

variable "alarm_actions" {
  description = "List of ARNs to notify when alarm is triggered"
  type        = list(string)
  default     = []
}

variable "ok_actions" {
  description = "List of ARNs to notify when alarm is cleared"
  type        = list(string)
  default     = []
}

# Tags
variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}