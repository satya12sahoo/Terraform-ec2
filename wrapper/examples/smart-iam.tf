# Example: Smart IAM Feature (Google-like)
# This demonstrates the smart IAM feature that intelligently determines whether to create
# an IAM role or just an instance profile based on what already exists

# Use the wrapper module with smart IAM feature
module "instances_with_smart_iam" {
  source = "../"

  # Basic configuration
  aws_region = "us-west-2"
  environment = "production"
  project_name = "smart-iam-example"

  # Instance configurations
  instances = {
    web_server = {
      name                        = "web-server"
      ami                         = "ami-0c02fb55956c7d316"
      instance_type              = "t3.micro"
      availability_zone          = "us-west-2a"
      subnet_id                  = "subnet-1234567890abcdef0"
      vpc_security_group_ids     = ["sg-1234567890abcdef0"]
      associate_public_ip_address = true
      key_name                   = "my-key-pair"
      
      user_data_template_vars = {
        hostname = "web-server"
        role     = "web"
      }
      
      root_block_device = {
        size       = 20
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "web-server-root"
        }
      }
      
      disable_api_stop       = false
      disable_api_termination = false
      ebs_optimized          = true
      monitoring             = true
      
      create_iam_instance_profile = false  # Smart IAM will handle this
      iam_role_policies          = {}
      
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
        instance_metadata_tags      = "enabled"
      }
      
      tags = {
        Name = "web-server"
        Role = "web"
      }
    }
    
    app_server = {
      name                        = "app-server"
      ami                         = "ami-0c02fb55956c7d316"
      instance_type              = "t3.small"
      availability_zone          = "us-west-2b"
      subnet_id                  = "subnet-1234567890abcdef1"
      vpc_security_group_ids     = ["sg-1234567890abcdef0"]
      associate_public_ip_address = false
      key_name                   = "my-key-pair"
      
      user_data_template_vars = {
        hostname = "app-server"
        role     = "application"
      }
      
      root_block_device = {
        size       = 30
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "app-server-root"
        }
      }
      
      disable_api_stop       = false
      disable_api_termination = false
      ebs_optimized          = true
      monitoring             = true
      
      create_iam_instance_profile = false  # Smart IAM will handle this
      iam_role_policies          = {}
      
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
        instance_metadata_tags      = "enabled"
      }
      
      tags = {
        Name = "app-server"
        Role = "application"
      }
    }
  }

  # Global settings
  global_settings = {
    enable_monitoring = true
    enable_ebs_optimization = true
    enable_termination_protection = false
    enable_stop_protection = false
    create_iam_profiles = false
    iam_role_policies = {}
    additional_tags = {
      Owner = "DevOps Team"
      CostCenter = "IT-001"
    }
  }

  # Smart IAM feature configuration
  enable_smart_iam = true
  smart_iam_role_name = "my-smart-ec2-role"
  smart_iam_role_description = "Smart IAM role for EC2 instances"
  smart_iam_role_path = "/"
  smart_iam_role_policies = {
    "S3ReadOnly" = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
    "CloudWatchAgent" = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    "SSMManagedInstanceCore" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  smart_iam_role_permissions_boundary = null
  smart_iam_role_tags = {
    Purpose = "Smart IAM Role"
    CreatedBy = "Terraform"
    Feature = "smart-iam"
    Environment = "production"
  }
  smart_instance_profile_tags = {
    Purpose = "Smart Instance Profile"
    CreatedBy = "Terraform"
    Feature = "smart-iam"
    Environment = "production"
  }
  smart_iam_force_create_role = false

  # User data template configuration
  user_data_template_path = "templates/user_data.sh"
  enable_user_data_template = true
}

# Smart IAM outputs
output "smart_iam_decision" {
  description = "Smart IAM decision made by the wrapper"
  value = module.instances_with_smart_iam.smart_iam_decision
}

output "smart_iam_instance_profile_arn" {
  description = "ARN of the smart IAM instance profile"
  value = module.instances_with_smart_iam.smart_iam_instance_profile_arn
}

output "smart_iam_instance_profile_name" {
  description = "Name of the smart IAM instance profile"
  value = module.instances_with_smart_iam.smart_iam_instance_profile_name
}

output "smart_iam_role_arn" {
  description = "ARN of the smart IAM role (if created)"
  value = module.instances_with_smart_iam.smart_iam_role_arn
}

output "smart_iam_role_name" {
  description = "Name of the smart IAM role (if created)"
  value = module.instances_with_smart_iam.smart_iam_role_name
}

output "smart_iam_existing_role_arn" {
  description = "ARN of the existing IAM role (if found in smart mode)"
  value = module.instances_with_smart_iam.smart_iam_existing_role_arn
}

output "smart_iam_existing_profile_arn" {
  description = "ARN of the existing IAM instance profile (if found in smart mode)"
  value = module.instances_with_smart_iam.smart_iam_existing_profile_arn
}

output "final_instance_profile_used" {
  description = "Final instance profile name used by all instances"
  value = module.instances_with_smart_iam.final_instance_profile_used
}

# Instance outputs
output "instance_ids" {
  description = "IDs of created instances"
  value = module.instances_with_smart_iam.instance_ids
}

output "instance_private_ips" {
  description = "Private IPs of created instances"
  value = module.instances_with_smart_iam.instance_private_ips
}

output "total_instances" {
  description = "Total number of instances created"
  value = module.instances_with_smart_iam.total_instances
}