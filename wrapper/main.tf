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
  
  # Explicitly set all required variables (no defaults)
  create = true
  name   = each.value.name
  
  # Instance configuration
  ami                         = each.value.ami
  instance_type              = each.value.instance_type
  availability_zone          = each.value.availability_zone
  subnet_id                  = each.value.subnet_id
  vpc_security_group_ids     = each.value.vpc_security_group_ids
  associate_public_ip_address = each.value.associate_public_ip_address
  key_name                   = each.value.key_name
  
  # User data (only if template is enabled)
  user_data_base64 = each.value.user_data
  
  # Block device configuration
  root_block_device = each.value.root_block_device
  
  # EBS volumes (if specified)
  ebs_volumes = each.value.ebs_volumes
  
  # Tags
  tags = each.value.tags
  
  # Additional instance settings
  disable_api_stop       = each.value.disable_api_stop
  disable_api_termination = each.value.disable_api_termination
  ebs_optimized          = each.value.ebs_optimized
  monitoring             = each.value.monitoring
  
  # IAM configuration
  create_iam_instance_profile = each.value.create_iam_instance_profile
  iam_role_policies          = each.value.iam_role_policies
  
  # Metadata options
  metadata_options = each.value.metadata_options
}