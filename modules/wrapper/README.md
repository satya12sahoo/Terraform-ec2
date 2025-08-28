Wrapper module for creating multiple EC2 instances using for_each

Overview

This wrapper consumes the root EC2 module in this repository and lets you define many instances at once via a single map variable. It shallow-merges an optional defaults map into each instance, so you can avoid repeating common settings.

Inputs

- instances (map(any))
  - Keyed by instance key, each value may include ANY of the root module inputs. Common keys include: name, region, subnet_id, instance_type, ami or ami_ssm_parameter, ignore_ami_changes, associate_public_ip_address, availability_zone, capacity_reservation_specification, cpu_options, cpu_credits, disable_api_stop, disable_api_termination, ebs_optimized, enclave_options_enabled, enable_primary_ipv6, ephemeral_block_device, get_password_data, hibernation, host_id, host_resource_group_arn, iam_instance_profile, instance_initiated_shutdown_behavior, instance_market_options, ipv6_address_count, ipv6_addresses, key_name, launch_template, maintenance_options, metadata_options, monitoring, network_interface, placement_group, placement_partition_number, private_dns_name_options, private_ip, root_block_device, secondary_private_ips, source_dest_check, tags, instance_tags, tenancy, user_data, user_data_base64, user_data_replace_on_change, volume_tags, enable_volume_tags, vpc_security_group_ids, timeouts, create_spot_instance, spot_instance_interruption_behavior, spot_launch_group, spot_price, spot_type, spot_wait_for_fulfillment, spot_valid_from, spot_valid_until, ebs_volumes, create_iam_instance_profile, iam_role_name, iam_role_use_name_prefix, iam_role_path, iam_role_description, iam_role_permissions_boundary, iam_role_policies, iam_role_tags, create_security_group, security_group_name, security_group_use_name_prefix, security_group_description, security_group_vpc_id, security_group_tags, security_group_egress_rules, security_group_ingress_rules, create_eip, eip_domain, eip_tags.

- defaults (any)
  - A map merged into every instance value (instance-specific values win). Useful for setting common region, subnet_id, tags, etc.

- putin_khuylo (bool)
  - Required flag from the root module; default true.

Outputs

- instances (map(object))
  - Map keyed by instance key with useful attributes: id, arn, instance_state, availability_zone, public_ip, private_ip, ipv6_addresses, tags_all, iam_role_name, iam_role_arn, iam_instance_profile_arn, iam_instance_profile_id, security_group_id, security_group_arn, root_block_device, ebs_block_device, ephemeral_block_device.

Usage

Example using a tfvars file to define multiple instances. Fill values in your tfvars file and reference it when applying.

Example

terraform
module "ec2s" {
  source = "../modules/wrapper"

  putin_khuylo = true

  defaults = {
    region   = "us-east-1"
    subnet_id = "subnet-xxxx"
    tags = {
      Project = "demo"
    }
  }

  instances = var.instances
}

Then in variables.tf at the caller level:

terraform
variable "instances" {
  description = "Instances map for wrapper"
  type        = any
}

And in your tfvars (e.g., terraform.tfvars):

hcl
instances = {
  web = {
    name           = "web-1"
    instance_type  = "t3.micro"
    ami_ssm_parameter = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
    create_security_group = true
  }
  worker = {
    name           = "worker-1"
    instance_type  = "t3.small"
    create_spot_instance = true
    spot_type = "one-time"
  }
}

Note

- The wrapper now forwards the full set of inputs from the base module. Provide only what you need; unspecified values fall back to base module defaults.
- See repository root README for detailed descriptions of each input.

Flow chart

```mermaid
flowchart TD
  A[Caller tfvars: defaults + instances] --> B[Wrapper locals: merge defaults into each instance]
  B --> C[for_each over instances]
  C --> D[Base EC2 module invocation]
  D --> E[Create Security Group (optional)]
  D --> F[Create IAM Role/Profile (optional)]
  D --> G[Create/Attach EBS volumes (optional)]
  D --> H[Create EIP (optional)]
  D --> I[Create EC2 or Spot Instance]
  I --> J[Outputs per instance]
  J --> K[Wrapper aggregated outputs (map by key)]
```


