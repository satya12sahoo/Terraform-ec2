variable "ec2instance" {
  description = "Map of EC2 instances to create"
  type        = any
  default     = {}
}



variable "defaults" {
  description = "Map of default values which will be used for each item."
  type        = any
  default     = {}
}
