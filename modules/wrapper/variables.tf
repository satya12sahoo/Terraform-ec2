variable "instances" {
  description = "Map of instance definitions keyed by instance key. Each value mirrors root module variables for a single instance (subset allowed)."
  type = map(object({
    # Common required/likely-used
    name                        = optional(string)
    region                      = optional(string)
    subnet_id                   = optional(string)
    instance_type               = optional(string, "t3.micro")
    ami                         = optional(string)
    ami_ssm_parameter           = optional(string)
    associate_public_ip_address = optional(bool)
    availability_zone           = optional(string)
    key_name                    = optional(string)
    vpc_security_group_ids      = optional(list(string))
    private_ip                  = optional(string)
    tags                        = optional(map(string), {})
    instance_tags               = optional(map(string), {})

    # IAM / SG / EIP toggles
    create_iam_instance_profile = optional(bool)
    iam_instance_profile        = optional(string)
    create_security_group       = optional(bool)
    security_group_vpc_id       = optional(string)
    create_eip                  = optional(bool)

    # Spot
    create_spot_instance                = optional(bool)
    spot_instance_interruption_behavior = optional(string)
    spot_price                          = optional(string)
    spot_type                           = optional(string)

    # Misc common
    user_data                   = optional(string)
    user_data_base64            = optional(string)
    user_data_replace_on_change = optional(bool)
    monitoring                  = optional(bool)
    metadata_options            = optional(object({
      http_endpoint               = optional(string, "enabled")
      http_protocol_ipv6          = optional(string)
      http_put_response_hop_limit = optional(number, 1)
      http_tokens                 = optional(string, "required")
      instance_metadata_tags      = optional(string)
    }))
  }))
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

