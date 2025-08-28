Wrapper module for creating multiple EC2 instances using for_each

Overview

This wrapper consumes the root EC2 module in this repository and lets you define many instances at once via a single map variable. It shallow-merges an optional defaults map into each instance, so you can avoid repeating common settings.

Inputs

- instances (map(object))
  - Keyed by an instance key. Each value may include a subset of the root module's variables, such as:
    - name (string)
    - region (string)
    - subnet_id (string)
    - instance_type (string) default "t3.micro"
    - ami (string) or ami_ssm_parameter (string)
    - associate_public_ip_address (bool)
    - availability_zone (string)
    - key_name (string)
    - vpc_security_group_ids (list(string))
    - private_ip (string)
    - tags (map(string)) and instance_tags (map(string))
    - create_iam_instance_profile (bool) or iam_instance_profile (string)
    - create_security_group (bool), security_group_vpc_id (string)
    - create_eip (bool)
    - create_spot_instance (bool), spot_instance_interruption_behavior, spot_price, spot_type
    - user_data, user_data_base64, user_data_replace_on_change
    - monitoring (bool)
    - metadata_options (object) { http_endpoint, http_protocol_ipv6, http_put_response_hop_limit, http_tokens, instance_metadata_tags }

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

- This wrapper forwards only a commonly-used subset of inputs. If you need additional inputs, extend modules/wrapper/variables.tf and modules/wrapper/main.tf to pass through more root variables.
- The root module contains many advanced options (EBS volumes, launch templates, advanced SG rules, etc.) that you may wire through similarly if needed.


