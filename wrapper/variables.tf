variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to use for all instances"
  type        = string
}

variable "availability_zones" {
  description = "List of availability zones to distribute instances across"
  type        = list(string)
}

variable "subnet_ids" {
  description = "List of subnet IDs where instances will be placed"
  type        = list(string)
}

variable "security_group_ids" {
  description = "List of security group IDs to attach to instances"
  type        = list(string)
}

variable "key_pair_name" {
  description = "Name of the EC2 key pair to use for SSH access"
  type        = string
}

# Optional variables for additional customization
variable "vpc_id" {
  description = "VPC ID where resources will be created"
  type        = string
  default     = null
}

variable "enable_monitoring" {
  description = "Enable detailed monitoring for instances"
  type        = bool
  default     = true
}

variable "enable_ebs_optimization" {
  description = "Enable EBS optimization for instances"
  type        = bool
  default     = true
}

variable "enable_termination_protection" {
  description = "Enable termination protection for instances"
  type        = bool
  default     = false
}

variable "enable_stop_protection" {
  description = "Enable stop protection for instances"
  type        = bool
  default     = false
}

variable "create_iam_profiles" {
  description = "Create IAM instance profiles for instances"
  type        = bool
  default     = false
}

variable "iam_role_policies" {
  description = "Map of IAM policies to attach to instance roles"
  type        = map(string)
  default     = {}
}

variable "additional_tags" {
  description = "Additional tags to apply to all instances"
  type        = map(string)
  default     = {}
}