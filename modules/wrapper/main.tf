locals {
  instance_defs = {
    for k, v in var.instances :
    k => merge(var.defaults, v)
  }
}

module "ec2" {
  source = "../.."

  for_each = local.instance_defs

  create       = true
  putin_khuylo = var.putin_khuylo

  name                          = try(each.value.name, null)
  region                        = try(each.value.region, null)
  subnet_id                     = try(each.value.subnet_id, null)
  instance_type                 = try(each.value.instance_type, null)
  ami                           = try(each.value.ami, null)
  ami_ssm_parameter             = try(each.value.ami_ssm_parameter, null)
  associate_public_ip_address   = try(each.value.associate_public_ip_address, null)
  availability_zone             = try(each.value.availability_zone, null)
  key_name                      = try(each.value.key_name, null)
  vpc_security_group_ids        = try(each.value.vpc_security_group_ids, null)
  private_ip                    = try(each.value.private_ip, null)
  tags                          = try(each.value.tags, {})
  instance_tags                 = try(each.value.instance_tags, {})

  # IAM / SG / EIP toggles
  create_iam_instance_profile = try(each.value.create_iam_instance_profile, null)
  iam_instance_profile        = try(each.value.iam_instance_profile, null)
  create_security_group       = try(each.value.create_security_group, null)
  security_group_vpc_id       = try(each.value.security_group_vpc_id, null)
  create_eip                  = try(each.value.create_eip, null)

  # Spot
  create_spot_instance                = try(each.value.create_spot_instance, null)
  spot_instance_interruption_behavior = try(each.value.spot_instance_interruption_behavior, null)
  spot_price                          = try(each.value.spot_price, null)
  spot_type                           = try(each.value.spot_type, null)

  # Misc common
  user_data                   = try(each.value.user_data, null)
  user_data_base64            = try(each.value.user_data_base64, null)
  user_data_replace_on_change = try(each.value.user_data_replace_on_change, null)
  monitoring                  = try(each.value.monitoring, null)
  metadata_options            = try(each.value.metadata_options, null)
}

