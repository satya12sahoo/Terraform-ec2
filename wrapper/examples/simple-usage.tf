# Simple usage example
# This demonstrates the basic usage of the wrapper

# Use the wrapper module
module "simple_instances" {
  source = "../"

  # Required variables
  aws_region = "us-west-2"
  environment = "development"
  project_name = "simple-app"

  # AMI and network configuration
  ami_id = "ami-0c02fb55956c7d316"  # Amazon Linux 2023 in us-west-2
  availability_zones = ["us-west-2a", "us-west-2b"]
  subnet_ids = ["subnet-1234567890abcdef0", "subnet-1234567890abcdef1"]
  security_group_ids = ["sg-1234567890abcdef0"]
  key_pair_name = "my-key-pair"

  # Optional configuration
  enable_monitoring = true
  enable_ebs_optimization = true
  enable_termination_protection = false
  enable_stop_protection = false

  additional_tags = {
    Owner = "DevOps Team"
    CostCenter = "IT-001"
  }
}

# Output the results
output "instance_ids" {
  description = "IDs of created instances"
  value = module.simple_instances.instance_ids
}

output "instance_private_ips" {
  description = "Private IPs of created instances"
  value = module.simple_instances.instance_private_ips
}

output "total_instances" {
  description = "Total number of instances created"
  value = module.simple_instances.total_instances
}