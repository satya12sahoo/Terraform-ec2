# Example: Creating IAM Instance Profile for Existing IAM Role
# This demonstrates how to create an instance profile for an existing IAM role

# Use the wrapper module with IAM instance profile creation
module "instances_with_iam_profile" {
  source = "../"

  # Basic configuration
  aws_region = "us-west-2"
  environment = "production"
  project_name = "iam-profile-example"

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
      
      create_iam_instance_profile = false  # We'll use the created instance profile
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
      
      create_iam_instance_profile = false  # We'll use the created instance profile
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

  # IAM Instance Profile for existing role configuration
  create_instance_profile_for_existing_role = true
  existing_iam_role_name = "my-existing-ec2-role"  # Your existing IAM role name
  instance_profile_name = "my-ec2-instance-profile"  # Custom name for the instance profile
  instance_profile_use_name_prefix = true
  instance_profile_path = "/"
  instance_profile_tags = {
    Purpose = "EC2 Instance Profile"
    CreatedBy = "Terraform"
    Environment = "production"
  }

  # User data template configuration
  user_data_template_path = "templates/user_data.sh"
  enable_user_data_template = true
}

# Outputs for IAM instance profile
output "iam_instance_profile_arn" {
  description = "ARN of the created IAM instance profile"
  value = module.instances_with_iam_profile.iam_instance_profile_arn
}

output "iam_instance_profile_name" {
  description = "Name of the created IAM instance profile"
  value = module.instances_with_iam_profile.iam_instance_profile_name
}

output "iam_instance_profile_id" {
  description = "ID of the created IAM instance profile"
  value = module.instances_with_iam_profile.iam_instance_profile_id
}

output "existing_iam_role_arn" {
  description = "ARN of the existing IAM role"
  value = module.instances_with_iam_profile.existing_iam_role_arn
}

output "existing_iam_role_name" {
  description = "Name of the existing IAM role"
  value = module.instances_with_iam_profile.existing_iam_role_name
}

# Instance outputs
output "instance_ids" {
  description = "IDs of created instances"
  value = module.instances_with_iam_profile.instance_ids
}

output "instance_private_ips" {
  description = "Private IPs of created instances"
  value = module.instances_with_iam_profile.instance_private_ips
}

output "total_instances" {
  description = "Total number of instances created"
  value = module.instances_with_iam_profile.total_instances
}