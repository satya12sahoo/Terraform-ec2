variable "name" {
  description = "Name tag for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
}

variable "ami" {
  description = "AMI ID to use. If null, latest Amazon Linux 2 will be used"
  type        = string
  default     = null
}

variable "subnet_id" {
  description = "Subnet ID to launch into. If null, default subnet will be used (if available)"
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

