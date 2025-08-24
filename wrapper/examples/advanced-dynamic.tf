# Advanced dynamic configuration example
# This demonstrates how to use external data sources and generate configurations dynamically

# Data sources for dynamic configuration
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

data "aws_subnets" "private" {
  filter {
    name   = "tag:Type"
    values = ["private"]
  }
}

data "aws_subnets" "public" {
  filter {
    name   = "tag:Type"
    values = ["public"]
  }
}

data "aws_security_groups" "web" {
  filter {
    name   = "tag:Name"
    values = ["web-sg"]
  }
}

data "aws_security_groups" "app" {
  filter {
    name   = "tag:Name"
    values = ["app-sg"]
  }
}

# Local variables for dynamic configuration
locals {
  # Environment-specific configurations
  env_configs = {
    development = {
      web_count = 1
      app_count = 1
      db_count  = 0
      web_instance_type = "t3.micro"
      app_instance_type = "t3.small"
      db_instance_type  = "t3.medium"
    }
    staging = {
      web_count = 2
      app_count = 1
      db_count  = 1
      web_instance_type = "t3.small"
      app_instance_type = "t3.medium"
      db_instance_type  = "t3.large"
    }
    production = {
      web_count = 3
      app_count = 2
      db_count  = 2
      web_instance_type = "t3.medium"
      app_instance_type = "t3.large"
      db_instance_type  = "t3.xlarge"
    }
  }

  current_env = local.env_configs[var.environment]

  # Generate web server configurations
  web_instances = {
    for i in range(local.current_env.web_count) : "web-${var.environment}-${i + 1}" => {
      name                        = "web-${var.environment}-${i + 1}"
      ami                         = data.aws_ami.amazon_linux.id
      instance_type              = local.current_env.web_instance_type
      availability_zone          = data.aws_availability_zones.available.names[i % length(data.aws_availability_zones.available.names)]
      subnet_id                  = data.aws_subnets.public.ids[i % length(data.aws_subnets.public.ids)]
      vpc_security_group_ids     = data.aws_security_groups.web.ids
      associate_public_ip_address = true
      key_name                   = var.key_pair_name
      
      user_data_template_vars = {
        hostname = "web-${var.environment}-${i + 1}"
        role     = "web"
        env      = var.environment
      }
      
      root_block_device = {
        size       = 20 + (i * 10)
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "web-${var.environment}-${i + 1}-root"
        }
      }
      
      disable_api_stop       = false
      disable_api_termination = false
      ebs_optimized          = true
      monitoring             = true
      
      create_iam_instance_profile = false
      iam_role_policies          = {}
      
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
        instance_metadata_tags      = "enabled"
      }
      
      tags = {
        Name        = "web-${var.environment}-${i + 1}"
        Role        = "web"
        Environment = var.environment
        Project     = var.project_name
        Instance    = i + 1
      }
    }
  }

  # Generate application server configurations
  app_instances = {
    for i in range(local.current_env.app_count) : "app-${var.environment}-${i + 1}" => {
      name                        = "app-${var.environment}-${i + 1}"
      ami                         = data.aws_ami.amazon_linux.id
      instance_type              = local.current_env.app_instance_type
      availability_zone          = data.aws_availability_zones.available.names[i % length(data.aws_availability_zones.available.names)]
      subnet_id                  = data.aws_subnets.private.ids[i % length(data.aws_subnets.private.ids)]
      vpc_security_group_ids     = data.aws_security_groups.app.ids
      associate_public_ip_address = false
      key_name                   = var.key_pair_name
      
      user_data_template_vars = {
        hostname = "app-${var.environment}-${i + 1}"
        role     = "application"
        env      = var.environment
      }
      
      root_block_device = {
        size       = 50 + (i * 25)
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "app-${var.environment}-${i + 1}-root"
        }
      }
      
      ebs_volumes = {
        "/dev/sdf" = {
          size       = 100 + (i * 50)
          type       = "gp3"
          encrypted  = true
          throughput = 125
          tags = {
            Name = "app-${var.environment}-${i + 1}-data"
            MountPoint = "/mnt/data"
          }
        }
      }
      
      disable_api_stop       = false
      disable_api_termination = false
      ebs_optimized          = true
      monitoring             = true
      
      create_iam_instance_profile = false
      iam_role_policies          = {}
      
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
        instance_metadata_tags      = "enabled"
      }
      
      tags = {
        Name        = "app-${var.environment}-${i + 1}"
        Role        = "application"
        Environment = var.environment
        Project     = var.project_name
        Instance    = i + 1
      }
    }
  }

  # Generate database server configurations (only for staging and production)
  db_instances = local.current_env.db_count > 0 ? {
    for i in range(local.current_env.db_count) : "db-${var.environment}-${i + 1}" => {
      name                        = "db-${var.environment}-${i + 1}"
      ami                         = data.aws_ami.amazon_linux.id
      instance_type              = local.current_env.db_instance_type
      availability_zone          = data.aws_availability_zones.available.names[i % length(data.aws_availability_zones.available.names)]
      subnet_id                  = data.aws_subnets.private.ids[i % length(data.aws_subnets.private.ids)]
      vpc_security_group_ids     = data.aws_security_groups.app.ids
      associate_public_ip_address = false
      key_name                   = var.key_pair_name
      
      user_data_template_vars = {
        hostname = "db-${var.environment}-${i + 1}"
        role     = "database"
        env      = var.environment
      }
      
      root_block_device = {
        size       = 100 + (i * 50)
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "db-${var.environment}-${i + 1}-root"
        }
      }
      
      ebs_volumes = {
        "/dev/sdf" = {
          size       = 500 + (i * 250)
          type       = "gp3"
          encrypted  = true
          throughput = 125
          tags = {
            Name = "db-${var.environment}-${i + 1}-data"
            MountPoint = "/mnt/database"
          }
        }
        "/dev/sdg" = {
          size       = 200 + (i * 100)
          type       = "gp3"
          encrypted  = true
          throughput = 125
          tags = {
            Name = "db-${var.environment}-${i + 1}-backup"
            MountPoint = "/mnt/backup"
          }
        }
      }
      
      disable_api_stop       = true
      disable_api_termination = true
      ebs_optimized          = true
      monitoring             = true
      
      create_iam_instance_profile = false
      iam_role_policies          = {}
      
      metadata_options = {
        http_endpoint               = "enabled"
        http_tokens                 = "required"
        http_put_response_hop_limit = 1
        instance_metadata_tags      = "enabled"
      }
      
      tags = {
        Name        = "db-${var.environment}-${i + 1}"
        Role        = "database"
        Environment = var.environment
        Project     = var.project_name
        Instance    = i + 1
      }
    }
  } : {}

  # Combine all instance configurations
  all_instances = merge(local.web_instances, local.app_instances, local.db_instances)
}

# Use the wrapper module with dynamically generated configurations
module "dynamic_instances" {
  source = "../"

  aws_region = var.aws_region
  environment = var.environment
  project_name = var.project_name

  # Use the dynamically generated instance configurations
  instances = local.all_instances

  # Global settings
  global_settings = {
    enable_monitoring = true
    enable_ebs_optimization = true
    enable_termination_protection = var.environment == "production"
    enable_stop_protection = var.environment == "production"
    create_iam_profiles = false
    iam_role_policies = {
      "CloudWatchAgent" = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    }
    additional_tags = {
      Owner       = "DevOps Team"
      CostCenter  = "IT-001"
      Backup      = "true"
      ManagedBy   = "terraform"
    }
  }

  user_data_template_path = "templates/user_data.sh"
  enable_user_data_template = true
}

# Variables for this example
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "development"
  validation {
    condition     = contains(["development", "staging", "production"], var.environment)
    error_message = "Environment must be one of: development, staging, production."
  }
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "dynamic-app"
}

variable "key_pair_name" {
  description = "EC2 key pair name"
  type        = string
  default     = "my-key-pair"
}

# Outputs
output "instance_ids" {
  description = "All instance IDs"
  value = module.dynamic_instances.instance_ids
}

output "instances_by_role" {
  description = "Instances grouped by role"
  value = module.dynamic_instances.instances_by_role
}

output "total_instances" {
  description = "Total number of instances created"
  value = module.dynamic_instances.total_instances
}

output "environment_config" {
  description = "Current environment configuration"
  value = local.current_env
}