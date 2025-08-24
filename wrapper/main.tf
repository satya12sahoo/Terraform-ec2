provider "aws" {
  region = var.aws_region
}

locals {
  # Define instance configurations with explicit values (no defaults)
  instance_configs = {
    web_server_1 = {
      name                        = "web-server-1"
      ami                         = var.ami_id
      instance_type              = "t3.micro"
      availability_zone          = var.availability_zones[0]
      subnet_id                  = var.subnet_ids[0]
      vpc_security_group_ids     = var.security_group_ids
      associate_public_ip_address = true
      key_name                   = var.key_pair_name
      user_data                  = base64encode(templatefile("${path.module}/templates/user_data.sh", {
        hostname = "web-server-1"
        role     = "web"
      }))
      root_block_device = {
        size       = 20
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "web-server-1-root"
        }
      }
      tags = {
        Name     = "web-server-1"
        Role     = "web"
        Environment = var.environment
        Project  = var.project_name
      }
    }
    
    web_server_2 = {
      name                        = "web-server-2"
      ami                         = var.ami_id
      instance_type              = "t3.small"
      availability_zone          = var.availability_zones[1]
      subnet_id                  = var.subnet_ids[1]
      vpc_security_group_ids     = var.security_group_ids
      associate_public_ip_address = true
      key_name                   = var.key_pair_name
      user_data                  = base64encode(templatefile("${path.module}/templates/user_data.sh", {
        hostname = "web-server-2"
        role     = "web"
      }))
      root_block_device = {
        size       = 30
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "web-server-2-root"
        }
      }
      tags = {
        Name     = "web-server-2"
        Role     = "web"
        Environment = var.environment
        Project  = var.project_name
      }
    }
    
    app_server_1 = {
      name                        = "app-server-1"
      ami                         = var.ami_id
      instance_type              = "t3.medium"
      availability_zone          = var.availability_zones[0]
      subnet_id                  = var.subnet_ids[0]
      vpc_security_group_ids     = var.security_group_ids
      associate_public_ip_address = false
      key_name                   = var.key_pair_name
      user_data                  = base64encode(templatefile("${path.module}/templates/user_data.sh", {
        hostname = "app-server-1"
        role     = "application"
      }))
      root_block_device = {
        size       = 50
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "app-server-1-root"
        }
      }
      ebs_volumes = {
        "/dev/sdf" = {
          size       = 100
          type       = "gp3"
          encrypted  = true
          throughput = 125
          tags = {
            Name = "app-server-1-data"
            MountPoint = "/mnt/data"
          }
        }
      }
      tags = {
        Name     = "app-server-1"
        Role     = "application"
        Environment = var.environment
        Project  = var.project_name
      }
    }
    
    db_server_1 = {
      name                        = "db-server-1"
      ami                         = var.ami_id
      instance_type              = "t3.large"
      availability_zone          = var.availability_zones[2]
      subnet_id                  = var.subnet_ids[2]
      vpc_security_group_ids     = var.security_group_ids
      associate_public_ip_address = false
      key_name                   = var.key_pair_name
      user_data                  = base64encode(templatefile("${path.module}/templates/user_data.sh", {
        hostname = "db-server-1"
        role     = "database"
      }))
      root_block_device = {
        size       = 100
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "db-server-1-root"
        }
      }
      ebs_volumes = {
        "/dev/sdf" = {
          size       = 500
          type       = "gp3"
          encrypted  = true
          throughput = 125
          tags = {
            Name = "db-server-1-data"
            MountPoint = "/mnt/database"
          }
        }
        "/dev/sdg" = {
          size       = 200
          type       = "gp3"
          encrypted  = true
          throughput = 125
          tags = {
            Name = "db-server-1-backup"
            MountPoint = "/mnt/backup"
          }
        }
      }
      tags = {
        Name     = "db-server-1"
        Role     = "database"
        Environment = var.environment
        Project  = var.project_name
      }
    }
  }
}

# Create EC2 instances using for_each loop with explicit configurations
module "ec2_instances" {
  source = "../"
  
  for_each = local.instance_configs
  
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
  user_data_base64           = each.value.user_data
  
  # Block device configuration
  root_block_device = each.value.root_block_device
  
  # EBS volumes (if specified)
  ebs_volumes = lookup(each.value, "ebs_volumes", {})
  
  # Tags
  tags = each.value.tags
  
  # Additional instance settings
  disable_api_stop       = false
  disable_api_termination = false
  ebs_optimized          = true
  
  # IAM configuration (if needed)
  create_iam_instance_profile = false
  
  # Monitoring
  monitoring = true
  
  # Metadata options
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
}