output "instance_ids" {
  description = "Map of instance names to their IDs"
  value = {
    for k, v in module.ec2_instances : k => v.instance_id
  }
}

output "instance_private_ips" {
  description = "Map of instance names to their private IP addresses"
  value = {
    for k, v in module.ec2_instances : k => v.private_ip
  }
}

output "instance_public_ips" {
  description = "Map of instance names to their public IP addresses"
  value = {
    for k, v in module.ec2_instances : k => v.public_ip
  }
}

output "instance_availability_zones" {
  description = "Map of instance names to their availability zones"
  value = {
    for k, v in module.ec2_instances : k => v.instance_availability_zone
  }
}

output "instance_arns" {
  description = "Map of instance names to their ARNs"
  value = {
    for k, v in module.ec2_instances : k => v.instance_arn
  }
}

output "instance_tags" {
  description = "Map of instance names to their tags"
  value = {
    for k, v in module.ec2_instances : k => v.instance_tags
  }
}

output "total_instances" {
  description = "Total number of instances created"
  value = length(module.ec2_instances)
}

output "instance_configurations" {
  description = "Map of instance names to their configurations"
  value = {
    for k, v in module.ec2_instances : k => {
      instance_type = v.instance_type
      ami           = v.ami
      subnet_id     = v.subnet_id
      tags          = v.instance_tags
    }
  }
}

output "instances_by_role" {
  description = "Instances grouped by their role tag"
  value = {
    for role in distinct([
      for k, v in module.ec2_instances : v.instance_tags["Role"]
    ]) : role => [
      for k, v in module.ec2_instances : k
      if v.instance_tags["Role"] == role
    ]
  }
}

# IAM Instance Profile outputs
output "iam_instance_profile_arn" {
  description = "ARN of the created IAM instance profile"
  value = var.create_instance_profile_for_existing_role && var.existing_iam_role_name != null ? 
    aws_iam_instance_profile.existing_role[0].arn : null
}

output "iam_instance_profile_name" {
  description = "Name of the created IAM instance profile"
  value = var.create_instance_profile_for_existing_role && var.existing_iam_role_name != null ? 
    aws_iam_instance_profile.existing_role[0].name : null
}

output "iam_instance_profile_id" {
  description = "ID of the created IAM instance profile"
  value = var.create_instance_profile_for_existing_role && var.existing_iam_role_name != null ? 
    aws_iam_instance_profile.existing_role[0].id : null
}

output "existing_iam_role_arn" {
  description = "ARN of the existing IAM role"
  value = var.create_instance_profile_for_existing_role && var.existing_iam_role_name != null ? 
    data.aws_iam_role.existing[0].arn : null
}

output "existing_iam_role_name" {
  description = "Name of the existing IAM role"
  value = var.create_instance_profile_for_existing_role && var.existing_iam_role_name != null ? 
    data.aws_iam_role.existing[0].name : null
}

# Smart IAM outputs
output "smart_iam_instance_profile_arn" {
  description = "ARN of the smart IAM instance profile"
  value = var.enable_smart_iam && var.smart_iam_role_name != null ? 
    aws_iam_instance_profile.smart_profile[0].arn : null
}

output "smart_iam_instance_profile_name" {
  description = "Name of the smart IAM instance profile"
  value = var.enable_smart_iam && var.smart_iam_role_name != null ? 
    aws_iam_instance_profile.smart_profile[0].name : null
}

output "smart_iam_instance_profile_id" {
  description = "ID of the smart IAM instance profile"
  value = var.enable_smart_iam && var.smart_iam_role_name != null ? 
    aws_iam_instance_profile.smart_profile[0].id : null
}

output "smart_iam_role_arn" {
  description = "ARN of the smart IAM role (if created)"
  value = var.enable_smart_iam && var.smart_iam_role_name != null && length(aws_iam_role.smart_role) > 0 ? 
    aws_iam_role.smart_role[0].arn : null
}

output "smart_iam_role_name" {
  description = "Name of the smart IAM role (if created)"
  value = var.enable_smart_iam && var.smart_iam_role_name != null && length(aws_iam_role.smart_role) > 0 ? 
    aws_iam_role.smart_role[0].name : null
}

output "smart_iam_role_id" {
  description = "ID of the smart IAM role (if created)"
  value = var.enable_smart_iam && var.smart_iam_role_name != null && length(aws_iam_role.smart_role) > 0 ? 
    aws_iam_role.smart_role[0].id : null
}

output "smart_iam_existing_role_arn" {
  description = "ARN of the existing IAM role (if found in smart mode)"
  value = var.enable_smart_iam && var.smart_iam_role_name != null && length(data.aws_iam_role.smart_existing_role) > 0 ? 
    data.aws_iam_role.smart_existing_role[0].arn : null
}

output "smart_iam_existing_profile_arn" {
  description = "ARN of the existing IAM instance profile (if found in smart mode)"
  value = var.enable_smart_iam && var.smart_iam_role_name != null && length(data.aws_iam_instance_profile.smart_existing_profile) > 0 ? 
    data.aws_iam_instance_profile.smart_existing_profile[0].arn : null
}

output "smart_iam_decision" {
  description = "Smart IAM decision made by the wrapper"
  value = var.enable_smart_iam && var.smart_iam_role_name != null ? (
    length(data.aws_iam_role.smart_existing_role) > 0 ? "Used existing IAM role" : (
      length(data.aws_iam_instance_profile.smart_existing_profile) > 0 ? "Created IAM role for existing instance profile" : (
        length(aws_iam_role.smart_role) > 0 ? "Created new IAM role and instance profile" : "No action taken"
      )
    )
  ) : "Smart IAM not enabled"
}

output "final_instance_profile_used" {
  description = "Final instance profile name used by all instances"
  value = local.instance_profile_name
}