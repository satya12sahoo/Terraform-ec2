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

# Additional variables from base module that can be configured globally
variable "create" {
  description = "Whether to create instances"
  type        = bool
  default     = true
}

variable "region" {
  description = "Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration"
  type        = string
  default     = null
}

variable "ami_ssm_parameter" {
  description = "SSM parameter name for the AMI ID. For Amazon Linux AMI SSM parameters see [reference](https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-public-parameters-ami.html)"
  type        = string
  default     = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

variable "ignore_ami_changes" {
  description = "Whether changes to the AMI ID changes should be ignored by Terraform. Note - changing this value will result in the replacement of the instance"
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
  description = "Defines CPU options to apply to the instance at launch time."
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
  description = "Whether Nitro Enclaves will be enabled on the instance. Defaults to `false`"
  type        = bool
  default     = null
}

variable "enable_primary_ipv6" {
  description = "Whether to assign a primary IPv6 Global Unicast Address (GUA) to the instance when launched in a dual-stack or IPv6-only subnet"
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

variable "host_id" {
  description = "ID of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host"
  type        = string
  default     = null
}

variable "host_resource_group_arn" {
  description = "ARN of the host resource group in which to launch the instances. If you specify an ARN, omit the `tenancy` parameter or set it to `host`"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = null
}

variable "instance_initiated_shutdown_behavior" {
  description = "Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instance"
  type        = string
  default     = null
}

variable "instance_market_options" {
  description = "The market (purchasing) option for the instance. If set, overrides the `create_spot_instance` variable"
  type = object({
    market_type = optional(string)
    spot_options = optional(object({
      instance_interruption_behavior = optional(string)
      max_price                      = optional(string)
      spot_instance_type             = optional(string)
      valid_until                    = optional(string)
    }))
  })
  default = null
}

variable "ipv6_address_count" {
  description = "A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet"
  type        = number
  default     = null
}

variable "ipv6_addresses" {
  description = "Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface"
  type        = list(string)
  default     = null
}

variable "launch_template" {
  description = "Specifies a Launch Template to configure the instance. Parameters configured on this resource will override the corresponding parameters in the Launch Template"
  type = object({
    id      = optional(string)
    name    = optional(string)
    version = optional(string)
  })
  default = null
}

variable "maintenance_options" {
  description = "The maintenance options for the instance"
  type = object({
    auto_recovery = optional(string)
  })
  default = null
}

variable "network_interface" {
  description = "Customize network interfaces to be attached at instance boot time"
  type = map(object({
    delete_on_termination = optional(bool)
    device_index          = optional(number)
    network_card_index    = optional(number)
    network_interface_id  = string
  }))
  default = null
}

variable "placement_group" {
  description = "The Placement Group to start the instance in"
  type        = string
  default     = null
}

variable "placement_partition_number" {
  description = "Number of the partition the instance is in. Valid only if the `aws_placement_group` resource's `strategy` argument is set to `partition`"
  type        = number
  default     = null
}

variable "private_dns_name_options" {
  description = "Customize the private DNS name options of the instance"
  type = object({
    enable_resource_name_dns_a_record    = optional(bool)
    enable_resource_name_dns_aaaa_record = optional(bool)
    hostname_type                        = optional(string)
  })
  default = null
}

variable "private_ip" {
  description = "Private IP address to associate with the instance in a VPC"
  type        = string
  default     = null
}

variable "secondary_private_ips" {
  description = "A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC"
  type        = list(string)
  default     = null
}

variable "source_dest_check" {
  description = "Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs"
  type        = bool
  default     = null
}

variable "instance_tags" {
  description = "Additional tags for the instance"
  type        = map(string)
  default     = {}
}

variable "tenancy" {
  description = "The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host"
  type        = string
  default     = null
}

variable "user_data" {
  description = "The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "Can be used instead of user_data to pass base64-encoded binary data directly"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true"
  type        = bool
  default     = null
}

variable "volume_tags" {
  description = "A mapping of tags to assign to the devices created by the instance at launch time"
  type        = map(string)
  default     = {}
}

variable "enable_volume_tags" {
  description = "Whether to enable volume tags (if enabled it conflicts with root_block_device tags)"
  type        = bool
  default     = true
}

variable "timeouts" {
  description = "Define maximum timeout for creating, updating, and deleting EC2 instance resources"
  type        = map(string)
  default     = {}
}

# Spot Instance variables
variable "create_spot_instance" {
  description = "Depicts if the instance is a spot instance"
  type        = bool
  default     = false
}

variable "spot_instance_interruption_behavior" {
  description = "Indicates Spot instance behavior when it is interrupted. Valid values are `terminate`, `stop`, or `hibernate`"
  type        = string
  default     = null
}

variable "spot_launch_group" {
  description = "A launch group is a group of spot instances that launch together and terminate together"
  type        = string
  default     = null
}

variable "spot_price" {
  description = "The maximum price to request on the spot market. Defaults to on-demand price"
  type        = string
  default     = null
}

variable "spot_type" {
  description = "If set to one-time, after the instance is terminated, the spot request will be closed"
  type        = string
  default     = null
}

variable "spot_wait_for_fulfillment" {
  description = "If set, Terraform will wait for the Spot Request to be fulfilled"
  type        = bool
  default     = null
}

variable "spot_valid_from" {
  description = "The start date and time of the request, in UTC RFC3339 format"
  type        = string
  default     = null
}

variable "spot_valid_until" {
  description = "The end date and time of the request, in UTC RFC3339 format"
  type        = string
  default     = null
}

# IAM Role / Instance Profile variables
variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_path" {
  description = "IAM role path"
  type        = string
  default     = null
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

variable "iam_role_permissions_boundary" {
  description = "ARN of the policy that is used to set the permissions boundary for the IAM role"
  type        = string
  default     = null
}

variable "iam_role_policies" {
  description = "Policies attached to the IAM role"
  type        = map(string)
  default     = {}
}

variable "iam_role_tags" {
  description = "A map of additional tags to add to the IAM role/profile created"
  type        = map(string)
  default     = {}
}

variable "iam_instance_profile" {
  description = "IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile"
  type        = string
  default     = null
}

# New variables for existing IAM role support
variable "existing_iam_role_name" {
  description = "Name of an existing IAM role to create an instance profile for"
  type        = string
  default     = null
}

variable "create_instance_profile_for_existing_role" {
  description = "Whether to create an IAM instance profile for an existing IAM role"
  type        = bool
  default     = false
}

variable "instance_profile_name" {
  description = "Name for the IAM instance profile (if not specified, will use the role name)"
  type        = string
  default     = null
}

variable "instance_profile_use_name_prefix" {
  description = "Determines whether the instance profile name is used as a prefix"
  type        = bool
  default     = true
}

variable "instance_profile_path" {
  description = "IAM instance profile path"
  type        = string
  default     = null
}

variable "instance_profile_tags" {
  description = "A map of additional tags to add to the IAM instance profile"
  type        = map(string)
  default     = {}
}

# Smart IAM feature variables (Toggle)
variable "enable_smart_iam" {
  description = "Enable smart IAM feature that automatically determines whether to create IAM role or just instance profile"
  type        = bool
  default     = false
}

variable "smart_iam_role_name" {
  description = "Name for the IAM role/instance profile in smart mode"
  type        = string
  default     = null
}

variable "smart_iam_role_description" {
  description = "Description for the IAM role in smart mode"
  type        = string
  default     = "Smart IAM role created by Terraform wrapper"
}

variable "smart_iam_role_path" {
  description = "IAM role path in smart mode"
  type        = string
  default     = "/"
}

variable "smart_iam_role_policies" {
  description = "Policies to attach to the IAM role in smart mode"
  type        = map(string)
  default     = {}
}

variable "smart_iam_role_permissions_boundary" {
  description = "Permissions boundary for the IAM role in smart mode"
  type        = string
  default     = null
}

variable "smart_iam_role_tags" {
  description = "Tags for the IAM role in smart mode"
  type        = map(string)
  default     = {}
}

variable "smart_instance_profile_tags" {
  description = "Tags for the instance profile in smart mode"
  type        = map(string)
  default     = {}
}

variable "smart_iam_force_create_role" {
  description = "Force creation of IAM role even if instance profile exists (for smart mode)"
  type        = bool
  default     = false
}

# Security Group variables
variable "create_security_group" {
  description = "Determines whether a security group will be created"
  type        = bool
  default     = false
}

variable "security_group_name" {
  description = "Name to use on security group created"
  type        = string
  default     = null
}

variable "security_group_use_name_prefix" {
  description = "Determines whether the security group name is used as a prefix"
  type        = bool
  default     = true
}

variable "security_group_description" {
  description = "Description of the security group"
  type        = string
  default     = null
}

variable "security_group_vpc_id" {
  description = "VPC ID to create the security group in"
  type        = string
  default     = null
}

variable "security_group_tags" {
  description = "A map of additional tags to add to the security group created"
  type        = map(string)
  default     = {}
}

variable "security_group_egress_rules" {
  description = "Egress rules to add to the security group"
  type = map(object({
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(number)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(number)
  }))
  default = {
    ipv4_default = {
      cidr_ipv4   = "0.0.0.0/0"
      description = "Allow all IPv4 traffic"
      ip_protocol = "-1"
    }
    ipv6_default = {
      cidr_ipv6   = "::/0"
      description = "Allow all IPv6 traffic"
      ip_protocol = "-1"
    }
  }
}

variable "security_group_ingress_rules" {
  description = "Ingress rules to add to the security group"
  type = map(object({
    cidr_ipv4                    = optional(string)
    cidr_ipv6                    = optional(string)
    description                  = optional(string)
    from_port                    = optional(number)
    ip_protocol                  = optional(string, "tcp")
    prefix_list_id               = optional(string)
    referenced_security_group_id = optional(string)
    tags                         = optional(map(string), {})
    to_port                      = optional(number)
  }))
  default = null
}

# Elastic IP variables
variable "create_eip" {
  description = "Determines whether a public EIP will be created and associated with the instance"
  type        = bool
  default     = false
}

variable "eip_domain" {
  description = "Indicates if this EIP is for use in VPC"
  type        = string
  default     = "vpc"
}

variable "eip_tags" {
  description = "A map of additional tags to add to the eip"
  type        = map(string)
  default     = {}
}

variable "putin_khuylo" {
  description = "Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity?"
  type        = bool
  default     = true
}

# Monitoring Module Integration
variable "enable_monitoring_module" {
  description = "Whether to enable the monitoring module"
  type        = bool
  default     = false
}

variable "monitoring" {
  description = "Monitoring module configuration"
  type = object({
    # CloudWatch Agent IAM Role
    create_cloudwatch_agent_role = optional(bool, true)
    cloudwatch_agent_role_name = optional(string, "cloudwatch-agent-role")
    cloudwatch_agent_role_name_prefix = optional(string, null)
    cloudwatch_agent_role_use_name_prefix = optional(bool, false)
    cloudwatch_agent_role_path = optional(string, "/")
    cloudwatch_agent_role_description = optional(string, "IAM role for CloudWatch agent on EC2 instances")
    cloudwatch_agent_role_tags = optional(map(string), {})
    cloudwatch_agent_instance_profile_name = optional(string, null)
    cloudwatch_agent_instance_profile_name_prefix = optional(string, null)
    cloudwatch_agent_instance_profile_use_name_prefix = optional(bool, false)
    cloudwatch_agent_instance_profile_path = optional(string, "/")
    cloudwatch_agent_instance_profile_tags = optional(map(string), {})
    cloudwatch_agent_policies = optional(map(string), {
      CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      CloudWatchLogsFullAccess    = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
    })
    
    # CloudWatch Dashboard
    create_dashboard = optional(bool, true)
    dashboard_name = optional(string, "ec2-monitoring-dashboard")
    dashboard_name_prefix = optional(string, null)
    dashboard_use_name_prefix = optional(bool, false)
    dashboard_tags = optional(map(string), {})
    
    # CloudWatch Alarms - CPU
    create_cpu_alarms = optional(bool, true)
    cpu_alarm_name = optional(string, null)
    cpu_alarm_name_prefix = optional(string, null)
    cpu_alarm_use_name_prefix = optional(bool, false)
    cpu_alarm_threshold = optional(number, 80)
    cpu_alarm_period = optional(number, 300)
    cpu_alarm_evaluation_periods = optional(number, 2)
    cpu_alarm_description = optional(string, "CPU utilization is too high")
    cpu_alarm_tags = optional(map(string), {})
    
    # CloudWatch Alarms - Memory
    create_memory_alarms = optional(bool, true)
    memory_alarm_name = optional(string, null)
    memory_alarm_name_prefix = optional(string, null)
    memory_alarm_use_name_prefix = optional(bool, false)
    memory_alarm_threshold = optional(number, 85)
    memory_alarm_period = optional(number, 300)
    memory_alarm_evaluation_periods = optional(number, 2)
    memory_alarm_description = optional(string, "Memory utilization is too high")
    memory_alarm_tags = optional(map(string), {})
    
    # CloudWatch Alarms - Disk
    create_disk_alarms = optional(bool, true)
    disk_alarm_name = optional(string, null)
    disk_alarm_name_prefix = optional(string, null)
    disk_alarm_use_name_prefix = optional(bool, false)
    disk_alarm_threshold = optional(number, 90)
    disk_alarm_period = optional(number, 300)
    disk_alarm_evaluation_periods = optional(number, 2)
    disk_alarm_description = optional(string, "Disk utilization is too high")
    disk_alarm_tags = optional(map(string), {})
    
    alarm_actions = optional(list(string), [])
    ok_actions = optional(list(string), [])
    alarm_tags = optional(map(string), {})
    
    # CloudWatch Log Groups
    create_log_groups = optional(bool, true)
    log_groups = optional(map(object({
      name              = string
      retention_in_days = number
      kms_key_id        = optional(string)
      tags              = optional(map(string), {})
    })), {
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
    })
    
    # SNS Topic
    create_sns_topic = optional(bool, false)
    sns_topic_name = optional(string, "ec2-alarm-notifications")
    sns_topic_name_prefix = optional(string, null)
    sns_topic_use_name_prefix = optional(bool, false)
    sns_topic_tags = optional(map(string), {})
    sns_subscription_tags = optional(map(string), {})
    sns_subscriptions = optional(map(object({
      protocol      = string
      endpoint      = string
      filter_policy = optional(string)
      tags          = optional(map(string), {})
    })), {})
    
    # CloudWatch Agent Configuration
    create_cloudwatch_agent_config = optional(bool, true)
    cloudwatch_agent_config_parameter_name = optional(string, "/cloudwatch-agent/config")
    cloudwatch_agent_config_parameter_name_prefix = optional(string, null)
    cloudwatch_agent_config_parameter_use_name_prefix = optional(bool, false)
    cloudwatch_agent_config_parameter_tags = optional(map(string), {})
    cloudwatch_agent_config_log_groups = optional(map(object({
      file_path = string
      log_group_name = string
      log_stream_name = string
      timezone = optional(string, "UTC")
      tags = optional(map(string), {})
    })), {})
    cloudwatch_agent_config_metrics = optional(map(object({
      measurement = list(string)
      metrics_collection_interval = number
      resources = optional(list(string), ["*"])
      tags = optional(map(string), {})
    })), {})
  })
  default = {}
  
  # =============================================================================
  # LOGGING MODULE CONFIGURATION
  # =============================================================================
  
  variable "enable_logging_module" {
    description = "Whether to enable the logging module"
    type        = bool
    default     = false
  }
  
  variable "logging" {
    description = "Configuration for the logging module"
    type = object({
      # CloudWatch Logs Configuration
      create_cloudwatch_log_groups = optional(bool, true)
      cloudwatch_log_groups = optional(map(object({
        name              = string
        retention_in_days = number
        kms_key_id        = optional(string)
        tags              = optional(map(string), {})
      })), {})
      
      # S3 Logging Configuration
      create_s3_logging_bucket = optional(bool, false)
      use_existing_s3_bucket = optional(bool, false)
      existing_s3_bucket_name = optional(string)
      existing_s3_bucket_arn = optional(string)
      s3_logging_bucket_name = optional(string)
      s3_logging_bucket_name_prefix = optional(string, "logging-bucket-")
      s3_logging_bucket_use_name_prefix = optional(bool, true)
      s3_logging_bucket_tags = optional(map(string), {})
      s3_logging_bucket_versioning = optional(bool, true)
      s3_logging_bucket_encryption_algorithm = optional(string, "AES256")
      s3_logging_bucket_kms_key_id = optional(string)
      s3_logging_bucket_bucket_key_enabled = optional(bool, true)
      s3_logging_bucket_block_public_access = optional(bool, true)
      s3_logging_bucket_lifecycle_rules = optional(list(object({
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
      })), [])
      s3_logging_upload_frequency = optional(string, "5m")
      s3_logging_compression = optional(string, "gzip")
      
      # Logging IAM Role Configuration
      create_logging_iam_role = optional(bool, true)
      logging_iam_role_name = optional(string, "ec2-logging-role")
      logging_iam_role_name_prefix = optional(string, "logging-role-")
      logging_iam_role_use_name_prefix = optional(bool, false)
      logging_iam_role_path = optional(string, "/")
      logging_iam_role_description = optional(string, "IAM role for EC2 logging services")
      logging_iam_role_tags = optional(map(string), {})
      logging_iam_role_policies = optional(map(string), {})
      
      # Logging Instance Profile Configuration
      logging_instance_profile_name = optional(string)
      logging_instance_profile_name_prefix = optional(string, "logging-profile-")
      logging_instance_profile_use_name_prefix = optional(bool, false)
      logging_instance_profile_path = optional(string, "/")
      logging_instance_profile_tags = optional(map(string), {})
      
      # Logging Agent Configuration
      create_logging_agent_config = optional(bool, true)
      logging_agent_config_parameter_name = optional(string, "/ec2/logging/agent-config")
      logging_agent_config_parameter_name_prefix = optional(string, "logging-config-")
      logging_agent_config_parameter_use_name_prefix = optional(bool, false)
      logging_agent_config_parameter_tags = optional(map(string), {})
      logging_agent_config_logs = optional(map(object({
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
      })), {})
      
      # Logging Alarms Configuration
      create_logging_alarms = optional(bool, true)
      logging_alarm_name = optional(string)
      logging_alarm_name_prefix = optional(string, "logging-alarm-")
      logging_alarm_use_name_prefix = optional(bool, false)
      logging_alarm_description = optional(string, "Log error count alarm")
      logging_alarm_threshold = optional(number, 10)
      logging_alarm_period = optional(number, 300)
      logging_alarm_evaluation_periods = optional(number, 2)
      logging_alarm_actions = optional(list(string), [])
      logging_ok_actions = optional(list(string), [])
      logging_alarm_tags = optional(map(string), {})
      
      # Logging SNS Configuration
      create_logging_sns_topic = optional(bool, false)
      logging_sns_topic_name = optional(string, "ec2-logging-notifications")
      logging_sns_topic_name_prefix = optional(string, "logging-topic-")
      logging_sns_topic_use_name_prefix = optional(bool, false)
      logging_sns_topic_tags = optional(map(string), {})
      logging_sns_subscriptions = optional(map(object({
        protocol = string
        endpoint = string
        filter_policy = optional(string)
        tags = optional(map(string), {})
      })), {})
      logging_sns_subscription_tags = optional(map(string), {})
      
      # Logging Dashboard Configuration
      create_logging_dashboard = optional(bool, true)
      logging_dashboard_name = optional(string, "ec2-logging-dashboard")
      logging_dashboard_name_prefix = optional(string, "logging-dashboard-")
      logging_dashboard_use_name_prefix = optional(bool, false)
      logging_dashboard_tags = optional(map(string), {})
    })
    default = {
      create_cloudwatch_log_groups = true
      create_logging_iam_role = true
      create_logging_agent_config = true
      create_logging_alarms = true
      create_logging_dashboard = true
      create_s3_logging_bucket = false
      create_logging_sns_topic = false
    }
  }
}