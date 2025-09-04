# Example: EC2 Monitoring with CloudWatch Agent
# This example demonstrates how to use the EC2 monitoring module

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# EC2 Instance (example)
resource "aws_instance" "example" {
  ami           = var.ami_id
  instance_type = var.instance_type
  
  iam_instance_profile = module.ec2_monitoring.iam_instance_profile_name
  
  user_data = base64encode(templatefile("${path.module}/user_data.sh", {
    ssm_parameter_name = module.ec2_monitoring.ssm_parameter_name
    aws_region         = var.aws_region
  }))
  
  tags = {
    Name        = var.instance_name
    Environment = var.environment
    Project     = var.project
  }
}

# EC2 Monitoring Module
module "ec2_monitoring" {
  source = "../../modules/ec2-monitoring"
  
  ec2_instance_name = var.instance_name
  aws_region       = var.aws_region
  
  # Customize monitoring settings
  cpu_alarm_threshold    = var.cpu_alarm_threshold
  memory_alarm_threshold = var.memory_alarm_threshold
  log_retention_days     = var.log_retention_days
  
  # Custom dashboard name
  dashboard_name = "${var.instance_name}-Monitoring-Dashboard"
  
  # SNS topic for alarms (if you have one)
  # alarm_actions = [var.sns_topic_arn]
  
  tags = {
    Environment = var.environment
    Project     = var.project
    Module      = "ec2-monitoring"
    Instance    = var.instance_name
  }
}

# Security Group for EC2 instance
resource "aws_security_group" "example" {
  name_prefix = "${var.instance_name}-sg"
  vpc_id      = var.vpc_id
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_cidr_blocks
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  tags = {
    Name        = "${var.instance_name}-sg"
    Environment = var.environment
    Project     = var.project
  }
}

# Attach security group to instance
resource "aws_network_interface_sg_attachment" "example" {
  security_group_id    = aws_security_group.example.id
  network_interface_id = aws_instance.example.primary_network_interface_id
}