variable "instances" {
  description = "Map of instance definitions keyed by instance key. Each value mirrors root module variables for a single instance. Accepts full set of base module inputs."
  type        = map(any)
}

variable "putin_khuylo" {
  description = "Carry-through required flag from the root module."
  type        = bool
  default     = true
}

variable "defaults" {
  description = "Default values applied to each instance (shallow-merge), keys match fields of instances values."
  type        = any
  default     = {}
}

