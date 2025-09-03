variable "name_prefix" {
  description = "Prefix used for naming monitoring resources"
  type        = string
}

variable "instance_id" {
  description = "EC2 instance ID to monitor"
  type        = string
}

variable "alarm_cpu_threshold" {
  description = "CPU utilization threshold percentage for alarm"
  type        = number
  default     = 80
}

variable "alarm_eval_periods" {
  description = "Number of periods for evaluation"
  type        = number
  default     = 3
}

variable "alarm_period_seconds" {
  description = "Period in seconds for each evaluation"
  type        = number
  default     = 60
}

variable "sns_topic_arn" {
  description = "Optional SNS topic ARN to notify on alarm"
  type        = string
  default     = null
}

