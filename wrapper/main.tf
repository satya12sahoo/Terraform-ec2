provider "aws" {
  region = var.aws_region
}

# Data sources for smart IAM feature
data "aws_iam_role" "existing" {
  count = var.create_instance_profile_for_existing_role && var.existing_iam_role_name != null ? 1 : 0
  name  = var.existing_iam_role_name
}

# Smart IAM data sources
data "aws_iam_role" "smart_existing_role" {
  count = var.enable_smart_iam && var.smart_iam_role_name != null ? 1 : 0
  name  = var.smart_iam_role_name
}

data "aws_iam_instance_profile" "smart_existing_profile" {
  count = var.enable_smart_iam && var.smart_iam_role_name != null ? 1 : 0
  name  = var.smart_iam_role_name
}

# Smart IAM role creation (only if role doesn't exist)
resource "aws_iam_role" "smart_role" {
  count = var.enable_smart_iam && var.smart_iam_role_name != null && 
          length(data.aws_iam_role.smart_existing_role) == 0 && 
          (var.smart_iam_force_create_role || length(data.aws_iam_instance_profile.smart_existing_profile) == 0) ? 1 : 0
  
  name = var.smart_iam_role_name
  path = var.smart_iam_role_path
  description = var.smart_iam_role_description
  permissions_boundary = var.smart_iam_role_permissions_boundary
  
  assume_role_policy = jsonencode({
    Version = var.assume_role_policy_version
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = var.ec2_service_principal
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
  
  tags = merge(
    var.smart_iam_role_tags,
    {
      Name        = var.smart_iam_role_name
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = var.managed_by_tag
      Feature     = var.feature_tag
    }
  )
}

# Smart IAM instance profile creation
resource "aws_iam_instance_profile" "smart_profile" {
  count = var.enable_smart_iam && var.smart_iam_role_name != null ? 1 : 0
  
  name = var.smart_iam_role_name
  path = var.smart_iam_role_path
  
  # Use existing role if it exists, otherwise use the created role
  role = length(data.aws_iam_role.smart_existing_role) > 0 ? 
         data.aws_iam_role.smart_existing_role[0].name : 
         (length(aws_iam_role.smart_role) > 0 ? aws_iam_role.smart_role[0].name : null)
  
  tags = merge(
    var.smart_instance_profile_tags,
    {
      Name        = var.smart_iam_role_name
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = var.managed_by_tag
      Feature     = var.feature_tag
    }
  )
}

# Attach policies to smart IAM role
resource "aws_iam_role_policy_attachment" "smart_policies" {
  for_each = var.enable_smart_iam && var.smart_iam_role_name != null && 
             length(var.smart_iam_role_policies) > 0 && 
             length(aws_iam_role.smart_role) > 0 ? var.smart_iam_role_policies : {}
  
  role       = aws_iam_role.smart_role[0].name
  policy_arn = each.value
}

# Create IAM instance profile for existing role (legacy feature)
resource "aws_iam_instance_profile" "existing_role" {
  count = var.create_instance_profile_for_existing_role && var.existing_iam_role_name != null ? 1 : 0
  
  name = var.instance_profile_name != null ? var.instance_profile_name : "${var.existing_iam_role_name}-instance-profile"
  path = var.instance_profile_path
  role = data.aws_iam_role.existing[0].name
  
  tags = merge(
    var.instance_profile_tags,
    {
      Name        = var.instance_profile_name != null ? var.instance_profile_name : "${var.existing_iam_role_name}-instance-profile"
      Role        = var.existing_iam_role_name
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = var.managed_by_tag
    }
  )
}

locals {
  # Determine which instance profile to use based on smart IAM or legacy mode
  smart_instance_profile_name = var.enable_smart_iam && var.smart_iam_role_name != null ? 
    aws_iam_instance_profile.smart_profile[0].name : null
  
  legacy_instance_profile_name = var.create_instance_profile_for_existing_role && var.existing_iam_role_name != null ? 
    aws_iam_instance_profile.existing_role[0].name : null
  
  # Priority: Smart IAM > Legacy > Manual
  instance_profile_name = coalesce(
    local.smart_instance_profile_name,
    local.legacy_instance_profile_name,
    var.iam_instance_profile
  )
  
  # Merge global settings with instance-specific settings
  merged_instances = {
    for instance_name, instance_config in var.instances : instance_name => merge(instance_config, {
      # Override with global settings if specified
      disable_api_stop       = var.global_settings.enable_stop_protection != null ? var.global_settings.enable_stop_protection : instance_config.disable_api_stop
      disable_api_termination = var.global_settings.enable_termination_protection != null ? var.global_settings.enable_termination_protection : instance_config.disable_api_termination
      ebs_optimized          = var.global_settings.enable_ebs_optimization != null ? var.global_settings.enable_ebs_optimization : instance_config.ebs_optimized
      monitoring             = var.global_settings.enable_monitoring != null ? var.global_settings.enable_monitoring : instance_config.monitoring
      
      # Merge IAM policies
      iam_role_policies = merge(
        var.global_settings.iam_role_policies,
        instance_config.iam_role_policies
      )
      
      # Merge additional tags
      tags = merge(
        var.global_settings.additional_tags,
        instance_config.tags,
        {
          Environment = var.environment
          Project     = var.project_name
          ManagedBy   = var.managed_by_tag
        }
      )
      
      # Generate user data based on configuration
      user_data = var.create_fresh_ec2 ? null : (
        var.enable_user_data_template && var.user_data_template_path != null ? (
          length(instance_config.user_data_template_vars) > 0 ? 
          base64encode(templatefile(var.user_data_template_path, instance_config.user_data_template_vars)) :
          base64encode(templatefile(var.user_data_template_path, {
            hostname = instance_config.name
            role     = lookup(instance_config.user_data_template_vars, "role", var.default_role_name)
          }))
        ) : (
          var.user_data != null ? var.user_data : null
        )
      )
    })
  }
}

# Create EC2 instances using for_each loop with dynamic configurations
module "ec2_instances" {
  source = "../"
  
  for_each = local.merged_instances
  
  # Basic instance configuration
  create = var.create
  name   = each.value.name
  region = var.region
  
  # Instance configuration
  ami                         = each.value.ami
  ami_ssm_parameter           = var.ami_ssm_parameter
  ignore_ami_changes          = var.ignore_ami_changes
  instance_type              = each.value.instance_type
  availability_zone          = each.value.availability_zone
  subnet_id                  = each.value.subnet_id
  vpc_security_group_ids     = each.value.vpc_security_group_ids
  associate_public_ip_address = each.value.associate_public_ip_address
  key_name                   = each.value.key_name
  
  # User data (only if template is enabled)
  user_data_base64 = each.value.user_data
  user_data = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change
  
  # Block device configuration
  root_block_device = each.value.root_block_device
  enable_volume_tags = var.enable_volume_tags
  volume_tags = var.volume_tags
  
  # EBS volumes (if specified)
  ebs_volumes = each.value.ebs_volumes
  
  # Tags
  tags = each.value.tags
  instance_tags = var.instance_tags
  
  # Additional instance settings
  disable_api_stop       = each.value.disable_api_stop
  disable_api_termination = each.value.disable_api_termination
  ebs_optimized          = each.value.ebs_optimized
  monitoring             = each.value.monitoring
  
  # IAM configuration
  create_iam_instance_profile = each.value.create_iam_instance_profile
  iam_role_policies          = each.value.iam_role_policies
  iam_role_name = var.iam_role_name
  iam_role_use_name_prefix = var.iam_role_use_name_prefix
  iam_role_path = var.iam_role_path
  iam_role_description = var.iam_role_description
  iam_role_permissions_boundary = var.iam_role_permissions_boundary
  iam_role_tags = var.iam_role_tags
  iam_instance_profile = local.instance_profile_name
  
  # Metadata options
  metadata_options = each.value.metadata_options
  
  # Additional instance configuration options
  capacity_reservation_specification = var.capacity_reservation_specification
  cpu_options = var.cpu_options
  cpu_credits = var.cpu_credits
  enclave_options_enabled = var.enclave_options_enabled
  enable_primary_ipv6 = var.enable_primary_ipv6
  ephemeral_block_device = var.ephemeral_block_device
  get_password_data = var.get_password_data
  hibernation = var.hibernation
  host_id = var.host_id
  host_resource_group_arn = var.host_resource_group_arn
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior
  instance_market_options = var.instance_market_options
  ipv6_address_count = var.ipv6_address_count
  ipv6_addresses = var.ipv6_addresses
  launch_template = var.launch_template
  maintenance_options = var.maintenance_options
  network_interface = var.network_interface
  placement_group = var.placement_group
  placement_partition_number = var.placement_partition_number
  private_dns_name_options = var.private_dns_name_options
  private_ip = var.private_ip
  secondary_private_ips = var.secondary_private_ips
  source_dest_check = var.source_dest_check
  tenancy = var.tenancy
  timeouts = var.timeouts
  
  # Spot instance configuration
  create_spot_instance = var.create_spot_instance
  spot_instance_interruption_behavior = var.spot_instance_interruption_behavior
  spot_launch_group = var.spot_launch_group
  spot_price = var.spot_price
  spot_type = var.spot_type
  spot_wait_for_fulfillment = var.spot_wait_for_fulfillment
  spot_valid_from = var.spot_valid_from
  spot_valid_until = var.spot_valid_until
  
  # Security group configuration
  create_security_group = var.create_security_group
  security_group_name = var.security_group_name
  security_group_use_name_prefix = var.security_group_use_name_prefix
  security_group_description = var.security_group_description
  security_group_vpc_id = var.security_group_vpc_id
  security_group_tags = var.security_group_tags
  security_group_egress_rules = var.security_group_egress_rules
  security_group_ingress_rules = var.security_group_ingress_rules
  
  # Elastic IP configuration
  create_eip = var.create_eip
  eip_domain = var.eip_domain
  eip_tags = var.eip_tags
  
  # Required variable
  putin_khuylo = var.putin_khuylo
}

# Monitoring Module Integration
module "monitoring" {
  count = var.enable_monitoring_module ? 1 : 0
  source = "../monitoring"
  
  aws_region = var.aws_region
  environment = var.environment
  instance_ids = values(module.ec2_instances)[*].id
  
  # CloudWatch Agent IAM Role
  create_cloudwatch_agent_role = var.monitoring.create_cloudwatch_agent_role
  cloudwatch_agent_role_name = var.monitoring.cloudwatch_agent_role_name
  cloudwatch_agent_role_name_prefix = var.monitoring.cloudwatch_agent_role_name_prefix
  cloudwatch_agent_role_use_name_prefix = var.monitoring.cloudwatch_agent_role_use_name_prefix
  cloudwatch_agent_role_path = var.monitoring.cloudwatch_agent_role_path
  cloudwatch_agent_role_description = var.monitoring.cloudwatch_agent_role_description
  cloudwatch_agent_role_tags = var.monitoring.cloudwatch_agent_role_tags
  cloudwatch_agent_instance_profile_name = var.monitoring.cloudwatch_agent_instance_profile_name
  cloudwatch_agent_instance_profile_name_prefix = var.monitoring.cloudwatch_agent_instance_profile_name_prefix
  cloudwatch_agent_instance_profile_use_name_prefix = var.monitoring.cloudwatch_agent_instance_profile_use_name_prefix
  cloudwatch_agent_instance_profile_path = var.monitoring.cloudwatch_agent_instance_profile_path
  cloudwatch_agent_instance_profile_tags = var.monitoring.cloudwatch_agent_instance_profile_tags
  cloudwatch_agent_policies = var.monitoring.cloudwatch_agent_policies
  
  # CloudWatch Dashboard
  create_dashboard = var.monitoring.create_dashboard
  dashboard_name = var.monitoring.dashboard_name
  dashboard_name_prefix = var.monitoring.dashboard_name_prefix
  dashboard_use_name_prefix = var.monitoring.dashboard_use_name_prefix
  dashboard_tags = var.monitoring.dashboard_tags
  
  # CloudWatch Alarms - CPU
  create_cpu_alarms = var.monitoring.create_cpu_alarms
  cpu_alarm_name = var.monitoring.cpu_alarm_name
  cpu_alarm_name_prefix = var.monitoring.cpu_alarm_name_prefix
  cpu_alarm_use_name_prefix = var.monitoring.cpu_alarm_use_name_prefix
  cpu_alarm_threshold = var.monitoring.cpu_alarm_threshold
  cpu_alarm_period = var.monitoring.cpu_alarm_period
  cpu_alarm_evaluation_periods = var.monitoring.cpu_alarm_evaluation_periods
  cpu_alarm_description = var.monitoring.cpu_alarm_description
  cpu_alarm_tags = var.monitoring.cpu_alarm_tags
  
  # CloudWatch Alarms - Memory
  create_memory_alarms = var.monitoring.create_memory_alarms
  memory_alarm_name = var.monitoring.memory_alarm_name
  memory_alarm_name_prefix = var.monitoring.memory_alarm_name_prefix
  memory_alarm_use_name_prefix = var.monitoring.memory_alarm_use_name_prefix
  memory_alarm_threshold = var.monitoring.memory_alarm_threshold
  memory_alarm_period = var.monitoring.memory_alarm_period
  memory_alarm_evaluation_periods = var.monitoring.memory_alarm_evaluation_periods
  memory_alarm_description = var.monitoring.memory_alarm_description
  memory_alarm_tags = var.monitoring.memory_alarm_tags
  
  # CloudWatch Alarms - Disk
  create_disk_alarms = var.monitoring.create_disk_alarms
  disk_alarm_name = var.monitoring.disk_alarm_name
  disk_alarm_name_prefix = var.monitoring.disk_alarm_name_prefix
  disk_alarm_use_name_prefix = var.monitoring.disk_alarm_use_name_prefix
  disk_alarm_threshold = var.monitoring.disk_alarm_threshold
  disk_alarm_period = var.monitoring.disk_alarm_period
  disk_alarm_evaluation_periods = var.monitoring.disk_alarm_evaluation_periods
  disk_alarm_description = var.monitoring.disk_alarm_description
  disk_alarm_tags = var.monitoring.disk_alarm_tags
  
  alarm_actions = var.monitoring.alarm_actions
  ok_actions = var.monitoring.ok_actions
  alarm_tags = var.monitoring.alarm_tags
  
  # CloudWatch Log Groups
  create_log_groups = var.monitoring.create_log_groups
  log_groups = var.monitoring.log_groups
  
  # SNS Topic
  create_sns_topic = var.monitoring.create_sns_topic
  sns_topic_name = var.monitoring.sns_topic_name
  sns_topic_name_prefix = var.monitoring.sns_topic_name_prefix
  sns_topic_use_name_prefix = var.monitoring.sns_topic_use_name_prefix
  sns_topic_tags = var.monitoring.sns_topic_tags
  sns_subscription_tags = var.monitoring.sns_subscription_tags
  sns_subscriptions = var.monitoring.sns_subscriptions
  
  # CloudWatch Agent Configuration
  create_cloudwatch_agent_config = var.monitoring.create_cloudwatch_agent_config
  cloudwatch_agent_config_parameter_name = var.monitoring.cloudwatch_agent_config_parameter_name
  cloudwatch_agent_config_parameter_name_prefix = var.monitoring.cloudwatch_agent_config_parameter_name_prefix
  cloudwatch_agent_config_parameter_use_name_prefix = var.monitoring.cloudwatch_agent_config_parameter_use_name_prefix
  cloudwatch_agent_config_parameter_tags = var.monitoring.cloudwatch_agent_config_parameter_tags
  cloudwatch_agent_config_log_groups = var.monitoring.cloudwatch_agent_config_log_groups
  cloudwatch_agent_config_metrics = var.monitoring.cloudwatch_agent_config_metrics
}

# =============================================================================
# LOGGING MODULE INTEGRATION
# =============================================================================

module "logging" {
  count = var.enable_logging_module ? 1 : 0
  source = "../logging"
  
  aws_region = var.aws_region
  environment = var.environment
  instance_ids = values(module.ec2_instances)[*].id
  
  # CloudWatch Logs Configuration
  create_cloudwatch_log_groups = var.logging.create_cloudwatch_log_groups
  cloudwatch_log_groups = var.logging.cloudwatch_log_groups
  
  # S3 Logging Configuration
  create_s3_logging_bucket = var.logging.create_s3_logging_bucket
  use_existing_s3_bucket = var.logging.use_existing_s3_bucket
  existing_s3_bucket_name = var.logging.existing_s3_bucket_name
  existing_s3_bucket_arn = var.logging.existing_s3_bucket_arn
  s3_logging_bucket_name = var.logging.s3_logging_bucket_name
  s3_logging_bucket_name_prefix = var.logging.s3_logging_bucket_name_prefix
  s3_logging_bucket_use_name_prefix = var.logging.s3_logging_bucket_use_name_prefix
  s3_logging_bucket_tags = var.logging.s3_logging_bucket_tags
  s3_logging_bucket_versioning = var.logging.s3_logging_bucket_versioning
  s3_logging_bucket_encryption_algorithm = var.logging.s3_logging_bucket_encryption_algorithm
  s3_logging_bucket_kms_key_id = var.logging.s3_logging_bucket_kms_key_id
  s3_logging_bucket_bucket_key_enabled = var.logging.s3_logging_bucket_bucket_key_enabled
  s3_logging_bucket_block_public_access = var.logging.s3_logging_bucket_block_public_access
  s3_logging_bucket_lifecycle_rules = var.logging.s3_logging_bucket_lifecycle_rules
  s3_logging_upload_frequency = var.logging.s3_logging_upload_frequency
  s3_logging_compression = var.logging.s3_logging_compression
  
  # Logging IAM Role Configuration
  create_logging_iam_role = var.logging.create_logging_iam_role
  logging_iam_role_name = var.logging.logging_iam_role_name
  logging_iam_role_name_prefix = var.logging.logging_iam_role_name_prefix
  logging_iam_role_use_name_prefix = var.logging.logging_iam_role_use_name_prefix
  logging_iam_role_path = var.logging.logging_iam_role_path
  logging_iam_role_description = var.logging.logging_iam_role_description
  logging_iam_role_tags = var.logging.logging_iam_role_tags
  logging_iam_role_policies = var.logging.logging_iam_role_policies
  
  # Logging Instance Profile Configuration
  logging_instance_profile_name = var.logging.logging_instance_profile_name
  logging_instance_profile_name_prefix = var.logging.logging_instance_profile_name_prefix
  logging_instance_profile_use_name_prefix = var.logging.logging_instance_profile_use_name_prefix
  logging_instance_profile_path = var.logging.logging_instance_profile_path
  logging_instance_profile_tags = var.logging.logging_instance_profile_tags
  
  # Logging Agent Configuration
  create_logging_agent_config = var.logging.create_logging_agent_config
  logging_agent_config_parameter_name = var.logging.logging_agent_config_parameter_name
  logging_agent_config_parameter_name_prefix = var.logging.logging_agent_config_parameter_name_prefix
  logging_agent_config_parameter_use_name_prefix = var.logging.logging_agent_config_parameter_use_name_prefix
  logging_agent_config_parameter_tags = var.logging.logging_agent_config_parameter_tags
  logging_agent_config_logs = var.logging.logging_agent_config_logs
  
  # Logging Alarms Configuration
  create_logging_alarms = var.logging.create_logging_alarms
  logging_alarm_name = var.logging.logging_alarm_name
  logging_alarm_name_prefix = var.logging.logging_alarm_name_prefix
  logging_alarm_use_name_prefix = var.logging.logging_alarm_use_name_prefix
  logging_alarm_description = var.logging.logging_alarm_description
  logging_alarm_threshold = var.logging.logging_alarm_threshold
  logging_alarm_period = var.logging.logging_alarm_period
  logging_alarm_evaluation_periods = var.logging.logging_alarm_evaluation_periods
  logging_alarm_actions = var.logging.logging_alarm_actions
  logging_ok_actions = var.logging.logging_ok_actions
  logging_alarm_tags = var.logging.logging_alarm_tags
  
  # Logging SNS Configuration
  create_logging_sns_topic = var.logging.create_logging_sns_topic
  logging_sns_topic_name = var.logging.logging_sns_topic_name
  logging_sns_topic_name_prefix = var.logging.logging_sns_topic_name_prefix
  logging_sns_topic_use_name_prefix = var.logging.logging_sns_topic_use_name_prefix
  logging_sns_topic_tags = var.logging.logging_sns_topic_tags
  logging_sns_subscriptions = var.logging.logging_sns_subscriptions
  logging_sns_subscription_tags = var.logging.logging_sns_subscription_tags
  
  # Logging Dashboard Configuration
  create_logging_dashboard = var.logging.create_logging_dashboard
  logging_dashboard_name = var.logging.logging_dashboard_name
  logging_dashboard_name_prefix = var.logging.logging_dashboard_name_prefix
  logging_dashboard_use_name_prefix = var.logging.logging_dashboard_use_name_prefix
  logging_dashboard_tags = var.logging.logging_dashboard_tags
}