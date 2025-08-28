output "instances" {
  description = "Aggregated outputs from child EC2 modules keyed by instance key"
  value = {
    for k, m in module.ec2 :
    k => {
      id                          = m.id
      arn                         = m.arn
      instance_state              = m.instance_state
      availability_zone           = m.availability_zone
      public_ip                   = try(m.public_ip, null)
      private_ip                  = try(m.private_ip, null)
      ipv6_addresses              = try(m.ipv6_addresses, [])
      tags_all                    = try(m.tags_all, {})
      iam_role_name               = try(m.iam_role_name, null)
      iam_role_arn                = try(m.iam_role_arn, null)
      iam_instance_profile_arn    = try(m.iam_instance_profile_arn, null)
      iam_instance_profile_id     = try(m.iam_instance_profile_id, null)
      security_group_id           = try(m.security_group_id, null)
      security_group_arn          = try(m.security_group_arn, null)
      root_block_device           = try(m.root_block_device, null)
      ebs_block_device            = try(m.ebs_block_device, null)
      ephemeral_block_device      = try(m.ephemeral_block_device, null)
    }
  }
}

