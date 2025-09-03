variable "create" {
  type    = bool
  default = true
}

variable "name" {
  type    = string
  default = "example-ec2"
}

variable "region" {
  type = string
}

variable "ami" {
  type    = string
  default = null
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}

variable "key_name" {
  type    = string
  default = null
}

variable "subnet_id" {
  type = string
}

variable "vpc_security_group_ids" {
  type    = list(string)
  default = []
}

variable "associate_public_ip_address" {
  type    = bool
  default = false
}

variable "instance_detailed_monitoring" {
  type    = bool
  default = true
}

variable "tags" {
  type    = map(string)
  default = {}
}

variable "alarm_name_prefix" {
  type = string
}

variable "create_default_alarms" {
  type    = bool
  default = true
}

variable "default_alarm_actions" {
  type    = list(string)
  default = []
}

variable "default_cpu" {
  type = object({
    comparison_operator = optional(string)
    evaluation_periods  = optional(number)
    threshold           = optional(number)
    period              = optional(number)
    statistic           = optional(string)
    treat_missing_data  = optional(string)
  })
  default = {}
}

variable "create_sns_topic" {
  type    = bool
  default = false
}

variable "sns_topic_name" {
  type    = string
  default = null
}

variable "sns_topic_arn" {
  type    = string
  default = null
}

variable "sns_kms_master_key_id" {
  type    = string
  default = null
}

variable "sns_subscriptions" {
  type = list(object({
    protocol = string
    endpoint = string
  }))
  default = []
}

variable "custom_alarms" {
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
  type    = bool
  default = false
}

variable "create_ssm_association" {
  type    = bool
  default = true
}

variable "ssm_document_name" {
  type    = string
  default = "AmazonCloudWatch-ManageAgent"
}

variable "cw_agent_action" {
  type    = string
  default = "configure"
}

variable "cw_agent_config_json" {
  type    = string
  default = null
}

variable "cw_agent_config_ssm_parameter_name" {
  type    = string
  default = null
}

