variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
  default     = "ec2-deployment"
}

variable "github_repository" {
  description = "GitHub repository name (e.g., owner/repo)"
  type        = string
  default     = "my-org/ec2-terraform"
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
  
  default = {}
}

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

variable "enable_user_data_template" {
  description = "Whether to use a user data template file or provide raw user data"
  type        = bool
  default     = false
}

variable "user_data_template_path" {
  description = "Path to the user data template file"
  type        = string
  default     = null
}

variable "create" {
  description = "Whether to create instances"
  type        = bool
  default     = true
}

variable "ami_ssm_parameter" {
  description = "SSM parameter name for the AMI ID"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "ignore_ami_changes" {
  description = "Whether changes to the AMI ID changes should be ignored by Terraform"
  type        = bool
  default     = false
}

variable "capacity_reservation_specification" {
  description = "Describes an instance's Capacity Reservation targeting option"
  type = object({
    capacity_reservation_preference = optional(string)
    capacity_reservation_target = optional(object({
      capacity_reservation_id                 = optional(string)
      capacity_reservation_resource_group_arn = optional(string)
    }))
  })
  default = null
}

variable "cpu_options" {
  description = "Defines CPU options to apply to the instance at launch time"
  type = object({
    amd_sev_snp      = optional(string)
    core_count       = optional(number)
    threads_per_core = optional(number)
  })
  default = null
}

variable "cpu_credits" {
  description = "The credit option for CPU usage (unlimited or standard)"
  type        = string
  default     = null
}

variable "enclave_options_enabled" {
  description = "Whether Nitro Enclaves will be enabled on the instance"
  type        = bool
  default     = null
}

variable "enable_primary_ipv6" {
  description = "Whether to assign a primary IPv6 Global Unicast Address (GUA) to the instance"
  type        = bool
  default     = null
}

variable "ephemeral_block_device" {
  description = "Customize Ephemeral (also known as Instance Store) volumes on the instance"
  type = map(object({
    device_name  = string
    no_device    = optional(bool)
    virtual_name = optional(string)
  }))
  default = null
}

variable "get_password_data" {
  description = "If true, wait for password data to become available and retrieve it"
  type        = bool
  default     = null
}

variable "hibernation" {
  description = "If true, the launched EC2 instance will support hibernation"
  type        = bool
  default     = null
}