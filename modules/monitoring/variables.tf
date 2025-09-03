variable "create" {
  description = "Whether to create monitoring resources"
  type        = bool
  default     = true
}

variable "tags" {
  description = "Tags to apply to created resources"
  type        = map(string)
  default     = {}
}

variable "instance_id" {
  description = "EC2 Instance ID that monitoring targets"
  type        = string
}

variable "alarm_name_prefix" {
  description = "Prefix for generated alarm names"
  type        = string
}

variable "default_alarm_actions" {
  description = "Default ARNs for alarm and OK actions. If empty and SNS is created or provided, will use that topic."
  type        = list(string)
  default     = []
}

variable "create_default_alarms" {
  description = "Create a minimal set of default EC2 alarms (CPU high, StatusCheck)"
  type        = bool
  default     = true
}

variable "default_cpu" {
  description = "Defaults for CPU high alarm"
  type = object({
    comparison_operator = optional(string, "GreaterThanOrEqualToThreshold")
    evaluation_periods  = optional(number, 2)
    threshold           = optional(number, 80)
    period              = optional(number, 60)
    statistic           = optional(string, "Average")
    treat_missing_data  = optional(string, "missing")
  })
  default = {}
}

variable "create_sns_topic" {
  description = "Create an SNS topic for alarms"
  type        = bool
  default     = false
}

variable "sns_topic_name" {
  description = "Name of the SNS topic to create"
  type        = string
  default     = null
}

variable "sns_topic_arn" {
  description = "Existing SNS topic ARN to use for alarms"
  type        = string
  default     = null
}

variable "sns_kms_master_key_id" {
  description = "KMS key ID or ARN for SNS topic encryption"
  type        = string
  default     = null
}

variable "sns_subscriptions" {
  description = "SNS subscriptions to attach to the created topic"
  type = list(object({
    protocol = string
    endpoint = string
  }))
  default = []
}

variable "alarms" {
  description = "Custom CloudWatch metric alarms to create"
  type = list(object({
    name                        = optional(string)
    alarm_description           = optional(string)
    comparison_operator         = string
    evaluation_periods          = number
    threshold                   = number
    metric_name                 = string
    namespace                   = string
    period                      = number
    statistic                   = optional(string)
    extended_statistic          = optional(string)
    datapoints_to_alarm         = optional(number)
    treat_missing_data          = optional(string)
    unit                        = optional(string)
    alarm_actions               = optional(list(string))
    ok_actions                  = optional(list(string))
    insufficient_data_actions   = optional(list(string))
    dimensions                  = optional(map(string))
  }))
  default = []
}

variable "enable_cloudwatch_agent" {
  description = "Whether to enable CloudWatch Agent via SSM association"
  type        = bool
  default     = false
}

variable "create_ssm_association" {
  description = "Create SSM association to manage CloudWatch Agent"
  type        = bool
  default     = true
}

variable "ssm_document_name" {
  description = "SSM document name to apply for CloudWatch Agent"
  type        = string
  default     = "AmazonCloudWatch-ManageAgent"
}

variable "cw_agent_action" {
  description = "CloudWatch Agent action for SSM doc (configure/start/stop)"
  type        = string
  default     = "configure"
}

variable "cw_agent_config_json" {
  description = "CloudWatch Agent JSON config payload"
  type        = string
  default     = null
}

variable "cw_agent_config_ssm_parameter_name" {
  description = "SSM Parameter Store name that contains CloudWatch Agent config JSON"
  type        = string
  default     = null
}

