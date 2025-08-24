# Advanced example showing dynamic instance creation
# This file demonstrates how to create instances dynamically based on external data

# Data source to get available AMIs
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

# Data source to get availability zones
data "aws_availability_zones" "available" {
  state = "available"
}

# Dynamic instance configuration based on environment
locals {
  # Base configuration that applies to all instances
  base_config = {
    ami                         = data.aws_ami.amazon_linux.id
    vpc_security_group_ids     = var.security_group_ids
    key_name                   = var.key_pair_name
    disable_api_stop           = false
    disable_api_termination    = false
    ebs_optimized              = true
    monitoring                 = true
    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 1
      instance_metadata_tags      = "enabled"
    }
  }

  # Environment-specific configurations
  environment_configs = {
    development = {
      web_instances = {
        count         = 1
        instance_type = "t3.micro"
        root_size     = 20
      }
      app_instances = {
        count         = 1
        instance_type = "t3.small"
        root_size     = 30
      }
      db_instances = {
        count         = 0  # No database in development
        instance_type = "t3.medium"
        root_size     = 50
      }
    }
    staging = {
      web_instances = {
        count         = 2
        instance_type = "t3.small"
        root_size     = 30
      }
      app_instances = {
        count         = 1
        instance_type = "t3.medium"
        root_size     = 50
      }
      db_instances = {
        count         = 1
        instance_type = "t3.large"
        root_size     = 100
      }
    }
    production = {
      web_instances = {
        count         = 3
        instance_type = "t3.medium"
        root_size     = 50
      }
      app_instances = {
        count         = 2
        instance_type = "t3.large"
        root_size     = 100
      }
      db_instances = {
        count         = 2
        instance_type = "t3.xlarge"
        root_size     = 200
      }
    }
  }

  # Get current environment config
  env_config = local.environment_configs[var.environment]

  # Generate web server configurations
  web_instances = {
    for i in range(local.env_config.web_instances.count) : "web-${var.environment}-${i + 1}" => merge(local.base_config, {
      name                        = "web-${var.environment}-${i + 1}"
      instance_type              = local.env_config.web_instances.instance_type
      availability_zone          = data.aws_availability_zones.available.names[i % length(data.aws_availability_zones.available.names)]
      subnet_id                  = var.subnet_ids[i % length(var.subnet_ids)]
      associate_public_ip_address = true
      user_data                  = base64encode(templatefile("${path.module}/../templates/user_data.sh", {
        hostname = "web-${var.environment}-${i + 1}"
        role     = "web"
      }))
      root_block_device = {
        size       = local.env_config.web_instances.root_size
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "web-${var.environment}-${i + 1}-root"
        }
      }
      tags = {
        Name        = "web-${var.environment}-${i + 1}"
        Role        = "web"
        Environment = var.environment
        Project     = var.project_name
        Instance    = i + 1
      }
    })
  }

  # Generate application server configurations
  app_instances = {
    for i in range(local.env_config.app_instances.count) : "app-${var.environment}-${i + 1}" => merge(local.base_config, {
      name                        = "app-${var.environment}-${i + 1}"
      instance_type              = local.env_config.app_instances.instance_type
      availability_zone          = data.aws_availability_zones.available.names[i % length(data.aws_availability_zones.available.names)]
      subnet_id                  = var.subnet_ids[i % length(var.subnet_ids)]
      associate_public_ip_address = false
      user_data                  = base64encode(templatefile("${path.module}/../templates/user_data.sh", {
        hostname = "app-${var.environment}-${i + 1}"
        role     = "application"
      }))
      root_block_device = {
        size       = local.env_config.app_instances.root_size
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "app-${var.environment}-${i + 1}-root"
        }
      }
      ebs_volumes = {
        "/dev/sdf" = {
          size       = local.env_config.app_instances.root_size * 2
          type       = "gp3"
          encrypted  = true
          throughput = 125
          tags = {
            Name = "app-${var.environment}-${i + 1}-data"
            MountPoint = "/mnt/data"
          }
        }
      }
      tags = {
        Name        = "app-${var.environment}-${i + 1}"
        Role        = "application"
        Environment = var.environment
        Project     = var.project_name
        Instance    = i + 1
      }
    })
  }

  # Generate database server configurations
  db_instances = {
    for i in range(local.env_config.db_instances.count) : "db-${var.environment}-${i + 1}" => merge(local.base_config, {
      name                        = "db-${var.environment}-${i + 1}"
      instance_type              = local.env_config.db_instances.instance_type
      availability_zone          = data.aws_availability_zones.available.names[i % length(data.aws_availability_zones.available.names)]
      subnet_id                  = var.subnet_ids[i % length(var.subnet_ids)]
      associate_public_ip_address = false
      user_data                  = base64encode(templatefile("${path.module}/../templates/user_data.sh", {
        hostname = "db-${var.environment}-${i + 1}"
        role     = "database"
      }))
      root_block_device = {
        size       = local.env_config.db_instances.root_size
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "db-${var.environment}-${i + 1}-root"
        }
      }
      ebs_volumes = {
        "/dev/sdf" = {
          size       = local.env_config.db_instances.root_size * 5
          type       = "gp3"
          encrypted  = true
          throughput = 125
          tags = {
            Name = "db-${var.environment}-${i + 1}-data"
            MountPoint = "/mnt/database"
          }
        }
        "/dev/sdg" = {
          size       = local.env_config.db_instances.root_size * 2
          type       = "gp3"
          encrypted  = true
          throughput = 125
          tags = {
            Name = "db-${var.environment}-${i + 1}-backup"
            MountPoint = "/mnt/backup"
          }
        }
      }
      tags = {
        Name        = "db-${var.environment}-${i + 1}"
        Role        = "database"
        Environment = var.environment
        Project     = var.project_name
        Instance    = i + 1
      }
    })
  }

  # Combine all instance configurations
  all_instances = merge(local.web_instances, local.app_instances, local.db_instances)
}

# Create instances using the dynamic configuration
module "dynamic_ec2_instances" {
  source = "../../"
  
  for_each = local.all_instances
  
  # Explicitly set all required variables
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
  user_data_base64           = each.value.user_data
  
  # Block device configuration
  root_block_device = each.value.root_block_device
  
  # EBS volumes (if specified)
  ebs_volumes = lookup(each.value, "ebs_volumes", {})
  
  # Tags
  tags = each.value.tags
  
  # Additional instance settings
  disable_api_stop       = each.value.disable_api_stop
  disable_api_termination = each.value.disable_api_termination
  ebs_optimized          = each.value.ebs_optimized
  monitoring             = each.value.monitoring
  
  # Metadata options
  metadata_options = each.value.metadata_options
}