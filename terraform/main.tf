terraform {
  required_version = ">= 1.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
  
  default_tags {
    tags = {
      Environment = var.environment
      Project     = var.project_name
      ManagedBy   = "terraform"
      Source      = "github.com/${var.github_repository}"
    }
  }
}

# Data sources for existing resources
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_security_group" "default" {
  name   = "default"
  vpc_id = data.aws_vpc.default.id
}

# Use the wrapper module to create EC2 instances
module "ec2_instances" {
  source = "../wrapper"
  
  aws_region   = var.aws_region
  environment  = var.environment
  project_name = var.project_name
  
  # Instance configurations
  instances = var.instances
  
  # Global settings
  global_settings = var.global_settings
  
  # User data template configuration
  enable_user_data_template = var.enable_user_data_template
  user_data_template_path   = var.user_data_template_path
  
  # Additional variables
  create = var.create
  region = var.aws_region
  
  # AMI configuration
  ami_ssm_parameter    = var.ami_ssm_parameter
  ignore_ami_changes   = var.ignore_ami_changes
  
  # Additional instance options
  capacity_reservation_specification = var.capacity_reservation_specification
  cpu_options                        = var.cpu_options
  cpu_credits                        = var.cpu_credits
  enclave_options_enabled            = var.enclave_options_enabled
  enable_primary_ipv6                = var.enable_primary_ipv6
  ephemeral_block_device             = var.ephemeral_block_device
  get_password_data                  = var.get_password_data
  hibernation                        = var.hibernation
}