provider "aws" {
  region = var.aws_region
}

locals {
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
          ManagedBy   = "terraform"
        }
      )
      
      # Generate user data based on template or use provided
      user_data = var.enable_user_data_template ? (
        length(instance_config.user_data_template_vars) > 0 ? 
        base64encode(templatefile(var.user_data_template_path, instance_config.user_data_template_vars)) :
        base64encode(templatefile(var.user_data_template_path, {
          hostname = instance_config.name
          role     = lookup(instance_config.user_data_template_vars, "role", "default")
        }))
      ) : null
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
  iam_instance_profile = var.iam_instance_profile
  
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