# Example: Using Existing IAM Role with Instance Profile
# This demonstrates how to use an IAM role that already exists and has an instance profile

# Use the wrapper module with existing IAM role and instance profile
module "instances_with_existing_iam" {
  source = "../"

  # Basic configuration
  aws_region = "us-west-2"
  environment = "production"
  project_name = "existing-iam-example"

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
      
      create_iam_instance_profile = false  # Use existing IAM instance profile
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
      
      create_iam_instance_profile = false  # Use existing IAM instance profile
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

  # Use existing IAM instance profile (no creation needed)
  iam_instance_profile = "my-existing-ec2-instance-profile"  # Your existing instance profile name

  # Disable all IAM creation features since we're using existing resources
  create_instance_profile_for_existing_role = false
  enable_smart_iam = false

  # User data template configuration
  user_data_template_path = "templates/user_data.sh"
  enable_user_data_template = true
}

# Outputs
output "instance_ids" {
  description = "IDs of created instances"
  value = module.instances_with_existing_iam.instance_ids
}

output "instance_private_ips" {
  description = "Private IPs of created instances"
  value = module.instances_with_existing_iam.instance_private_ips
}

output "total_instances" {
  description = "Total number of instances created"
  value = module.instances_with_existing_iam.total_instances
}

output "final_instance_profile_used" {
  description = "Final instance profile name used by all instances"
  value = module.instances_with_existing_iam.final_instance_profile_used
}