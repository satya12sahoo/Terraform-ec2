variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "instances" {
  description = "Map of instance configurations. Each key is the instance name, value contains the full configuration."
  type = map(object({
    # Basic instance configuration
    name                        = string
    ami                         = string
    instance_type              = string
    availability_zone          = string
    subnet_id                  = string
    vpc_security_group_ids     = list(string)
    associate_public_ip_address = bool
    key_name                   = string
    
    # User data configuration
    user_data_template_vars = optional(map(string), {})
    
    # Block device configuration
    root_block_device = object({
      size       = number
      type       = string
      encrypted  = bool
      throughput = optional(number, 125)
      tags       = optional(map(string), {})
    })
    
    # EBS volumes (optional)
    ebs_volumes = optional(map(object({
      size       = number
      type       = string
      encrypted  = bool
      throughput = optional(number, 125)
      tags       = optional(map(string), {})
    })), {})
    
    # Instance settings
    disable_api_stop       = optional(bool, false)
    disable_api_termination = optional(bool, false)
    ebs_optimized          = optional(bool, true)
    monitoring             = optional(bool, true)
    
    # IAM configuration
    create_iam_instance_profile = optional(bool, false)
    iam_role_policies          = optional(map(string), {})
    
    # Metadata options
    metadata_options = optional(object({
      http_endpoint               = optional(string, "enabled")
      http_tokens                 = optional(string, "required")
      http_put_response_hop_limit = optional(number, 1)
      instance_metadata_tags      = optional(string, "enabled")
    }), {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 1
      instance_metadata_tags      = "enabled"
    })
    
    # Tags
    tags = map(string)
  }))
  
  validation {
    condition = length(var.instances) > 0
    error_message = "At least one instance must be defined in the instances map."
  }
}

# Optional global settings that can override instance-specific settings
variable "global_settings" {
  description = "Global settings that can override instance-specific configurations"
  type = object({
    enable_monitoring = optional(bool, true)
    enable_ebs_optimization = optional(bool, true)
    enable_termination_protection = optional(bool, false)
    enable_stop_protection = optional(bool, false)
    create_iam_profiles = optional(bool, false)
    iam_role_policies = optional(map(string), {})
    additional_tags = optional(map(string), {})
  })
  default = {
    enable_monitoring = true
    enable_ebs_optimization = true
    enable_termination_protection = false
    enable_stop_protection = false
    create_iam_profiles = false
    iam_role_policies = {}
    additional_tags = {}
  }
}

variable "user_data_template_path" {
  description = "Path to the user data template file"
  type        = string
  default     = "templates/user_data.sh"
}

variable "enable_user_data_template" {
  description = "Whether to use the user data template or provide raw user data"
  type        = bool
  default     = true
}