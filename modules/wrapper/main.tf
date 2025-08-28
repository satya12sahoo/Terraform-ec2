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

  # Direct base inputs
  name                          = try(each.value.name, null)
  region                        = try(each.value.region, null)
  subnet_id                     = try(each.value.subnet_id, null)
  instance_type                 = try(each.value.instance_type, null)
  ami                           = try(each.value.ami, null)
  ami_ssm_parameter             = try(each.value.ami_ssm_parameter, null)
  ignore_ami_changes            = try(each.value.ignore_ami_changes, null)
  associate_public_ip_address   = try(each.value.associate_public_ip_address, null)
  availability_zone             = try(each.value.availability_zone, null)
  capacity_reservation_specification = try(each.value.capacity_reservation_specification, null)
  cpu_options                   = try(each.value.cpu_options, null)
  cpu_credits                   = try(each.value.cpu_credits, null)
  disable_api_stop              = try(each.value.disable_api_stop, null)
  disable_api_termination       = try(each.value.disable_api_termination, null)
  ebs_optimized                 = try(each.value.ebs_optimized, null)
  enclave_options_enabled       = try(each.value.enclave_options_enabled, null)
  enable_primary_ipv6           = try(each.value.enable_primary_ipv6, null)
  ephemeral_block_device        = try(each.value.ephemeral_block_device, null)
  get_password_data             = try(each.value.get_password_data, null)
  hibernation                   = try(each.value.hibernation, null)
  host_id                       = try(each.value.host_id, null)
  host_resource_group_arn       = try(each.value.host_resource_group_arn, null)
  iam_instance_profile          = try(each.value.iam_instance_profile, null)
  instance_initiated_shutdown_behavior = try(each.value.instance_initiated_shutdown_behavior, null)
  instance_market_options       = try(each.value.instance_market_options, null)
  ipv6_address_count            = try(each.value.ipv6_address_count, null)
  ipv6_addresses                = try(each.value.ipv6_addresses, null)
  key_name                      = try(each.value.key_name, null)
  launch_template               = try(each.value.launch_template, null)
  maintenance_options           = try(each.value.maintenance_options, null)
  metadata_options              = try(each.value.metadata_options, null)
  monitoring                    = try(each.value.monitoring, null)
  network_interface             = try(each.value.network_interface, null)
  placement_group               = try(each.value.placement_group, null)
  placement_partition_number    = try(each.value.placement_partition_number, null)
  private_dns_name_options      = try(each.value.private_dns_name_options, null)
  private_ip                    = try(each.value.private_ip, null)
  root_block_device             = try(each.value.root_block_device, null)
  secondary_private_ips         = try(each.value.secondary_private_ips, null)
  source_dest_check             = try(each.value.source_dest_check, null)
  tags                          = try(each.value.tags, {})
  instance_tags                 = try(each.value.instance_tags, {})
  tenancy                       = try(each.value.tenancy, null)
  user_data                     = try(each.value.user_data, null)
  user_data_base64              = try(each.value.user_data_base64, null)
  user_data_replace_on_change   = try(each.value.user_data_replace_on_change, null)
  volume_tags                   = try(each.value.volume_tags, {})
  enable_volume_tags            = try(each.value.enable_volume_tags, null)
  vpc_security_group_ids        = try(each.value.vpc_security_group_ids, null)
  timeouts                      = try(each.value.timeouts, null)

  # Spot
  create_spot_instance                = try(each.value.create_spot_instance, null)
  spot_instance_interruption_behavior = try(each.value.spot_instance_interruption_behavior, null)
  spot_launch_group                   = try(each.value.spot_launch_group, null)
  spot_price                          = try(each.value.spot_price, null)
  spot_type                           = try(each.value.spot_type, null)
  spot_wait_for_fulfillment           = try(each.value.spot_wait_for_fulfillment, null)
  spot_valid_from                     = try(each.value.spot_valid_from, null)
  spot_valid_until                    = try(each.value.spot_valid_until, null)

  # EBS Volumes
  ebs_volumes = try(each.value.ebs_volumes, null)

  # IAM / Instance Profile
  create_iam_instance_profile = try(each.value.create_iam_instance_profile, null)
  iam_role_name               = try(each.value.iam_role_name, null)
  iam_role_use_name_prefix    = try(each.value.iam_role_use_name_prefix, null)
  iam_role_path               = try(each.value.iam_role_path, null)
  iam_role_description        = try(each.value.iam_role_description, null)
  iam_role_permissions_boundary = try(each.value.iam_role_permissions_boundary, null)
  iam_role_policies           = try(each.value.iam_role_policies, null)
  iam_role_tags               = try(each.value.iam_role_tags, null)

  # Security Group
  create_security_group        = try(each.value.create_security_group, null)
  security_group_name          = try(each.value.security_group_name, null)
  security_group_use_name_prefix = try(each.value.security_group_use_name_prefix, null)
  security_group_description   = try(each.value.security_group_description, null)
  security_group_vpc_id        = try(each.value.security_group_vpc_id, null)
  security_group_tags          = try(each.value.security_group_tags, null)
  security_group_egress_rules  = try(each.value.security_group_egress_rules, null)
  security_group_ingress_rules = try(each.value.security_group_ingress_rules, null)

  # EIP
  create_eip = try(each.value.create_eip, null)
  eip_domain = try(each.value.eip_domain, null)
  eip_tags   = try(each.value.eip_tags, null)
}

