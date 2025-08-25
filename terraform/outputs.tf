# Instance Information
output "instance_ids" {
  description = "Map of instance names to their IDs"
  value       = module.ec2_instances.instance_ids
}

output "instance_private_ips" {
  description = "Map of instance names to their private IP addresses"
  value       = module.ec2_instances.instance_private_ips
}

output "instance_public_ips" {
  description = "Map of instance names to their public IP addresses"
  value       = module.ec2_instances.instance_public_ips
}

output "instance_availability_zones" {
  description = "Map of instance names to their availability zones"
  value       = module.ec2_instances.instance_availability_zones
}

output "instance_arns" {
  description = "Map of instance names to their ARNs"
  value       = module.ec2_instances.instance_arns
}

output "instance_tags" {
  description = "Map of instance names to their tags"
  value       = module.ec2_instances.instance_tags
}

output "total_instances" {
  description = "Total number of instances created"
  value       = module.ec2_instances.total_instances
}

output "instance_configurations" {
  description = "Map of instance names to their configurations"
  value       = module.ec2_instances.instance_configurations
}

output "instances_by_role" {
  description = "Instances grouped by their role tag"
  value       = module.ec2_instances.instances_by_role
}

# IAM Information
output "iam_instance_profile_arn" {
  description = "ARN of the created IAM instance profile"
  value       = module.ec2_instances.iam_instance_profile_arn
}

output "iam_instance_profile_name" {
  description = "Name of the created IAM instance profile"
  value       = module.ec2_instances.iam_instance_profile_name
}

output "iam_instance_profile_id" {
  description = "ID of the created IAM instance profile"
  value       = module.ec2_instances.iam_instance_profile_id
}

# Deployment Summary
output "deployment_summary" {
  description = "Summary of the EC2 deployment"
  value = {
    environment = var.environment
    region      = var.aws_region
    project     = var.project_name
    instances   = module.ec2_instances.total_instances
    instance_ids = module.ec2_instances.instance_ids
  }
}