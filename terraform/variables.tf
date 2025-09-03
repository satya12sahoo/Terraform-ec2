variable "aws_region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-1"
}

variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "example-ec2"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "ami" {
  description = "AMI ID to use. If null, latest Amazon Linux 2 will be used"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID to launch the instance into. If null, default subnet will be used (if available)"
  type        = string
  default     = null
}

variable "vpc_security_group_ids" {
  description = "List of security group IDs to associate. If empty, a basic SSH SG will be created"
  type        = list(string)
  default     = []
}

variable "key_name" {
  description = "Name of an existing EC2 Key Pair for SSH"
  type        = string
  default     = null
}

variable "iam_instance_profile" {
  description = "Name of an IAM instance profile to attach"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script (plain text)"
  type        = string
  default     = null
}

variable "volume_size_gb" {
  description = "Root volume size in GB"
  type        = number
  default     = 8
}

variable "tags" {
  description = "Additional tags to add to resources"
  type        = map(string)
  default     = {}
}

variable "alarm_cpu_threshold" {
  description = "CPUUtilization threshold percentage for alarm"
  type        = number
  default     = 80
}

variable "alarm_eval_periods" {
  description = "Number of evaluation periods for the CPU alarm"
  type        = number
  default     = 3
}

variable "alarm_period_seconds" {
  description = "Period in seconds for collecting CPU metrics"
  type        = number
  default     = 60
}

variable "sns_topic_arn" {
  description = "Optional SNS topic ARN for alarm notifications"
  type        = string
  default     = null
}

