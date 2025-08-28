variable "role_name" {
  description = "Name of the existing IAM role to associate with the instance profile"
  type        = string
}

variable "name" {
  description = "Base name for the instance profile"
  type        = string
  default     = "ec2-profile"
}

variable "use_name_prefix" {
  description = "Use name as prefix for the instance profile"
  type        = bool
  default     = true
}

variable "path" {
  description = "Path for the instance profile"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to the instance profile"
  type        = map(string)
  default     = {}
}

