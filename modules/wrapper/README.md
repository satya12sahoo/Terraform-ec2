# EC2-Instance Module

This module wraps the [EC2 instance base module] . and allows you to create **multiple EC2 instances** with shared defaults and per-instance overrides.

It uses a **two-level input pattern**:

* `defaults` → global baseline values for all instances
* `ec2instance` → map of instance-specific configurations (overrides `defaults`)

---

## Usage

```hcl
module "ec2_wrapper" {
  source = "./modules/wrapper"

  defaults = {
    instance_type = "t3.micro"
    key_name      = "default-key"
    subnet_id     = "subnet-123456"
    tags = {
      Environment = "dev"
    }
  }

  ec2instance = {
    app1 = {
      name          = "app-server"
      instance_type = "t3.small"
      user_data     = file("userdata.sh")
      tags = {
        Role = "app"
      }
    }

    db1 = {
      name          = "db-server"
      instance_type = "t3.medium"
      create_iam_instance_profile = true
      ebs_volumes = {
        data = {
          size        = 50
          type        = "gp3"
          device_name = "/dev/sdh"
        }
      }
      tags = {
        Role = "database"
      }
    }

    spot1 = {
      name                 = "spot-worker"
      instance_type        = "t3.large"
      create_spot_instance = true
      spot_price           = "0.02"
      tags = {
        Role = "batch"
      }
    }
  }
}
```

---

## Wrapper Module Inputs

These are **wrapper-level variables**:

| Name       | Type     | Default | Description                                                                                           |
| ---------- | -------- | ------- | ----------------------------------------------------------------------------------------------------- |
| `defaults` | object   | `{}`    | Default values applied to all instances. Each key corresponds to a child module variable (see below). |
| `ec2instance`    | map(any) | `{}`    | Map of EC2 instances to create. Each entry can override values from `defaults`.                       |

---

## Module Inputs

The ec2instance modules passes all inputs through to the **child EC2 instance module**. Below is a categorized list of **all supported inputs**.

---

### General

| Name                 | Type   | Default                                                                 | Description                   |
| -------------------- | ------ | ----------------------------------------------------------------------- | ----------------------------- |
| `create`             | bool   | `true`                                                                  | Whether to create an instance |
| `name`               | string | `""`                                                                    | Name of the EC2 instance      |
| `ami`                | string | `null`                                                                  | AMI ID to use                 |
| `ami_ssm_parameter`  | string | `/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64` | SSM parameter name for AMI ID |
| `ignore_ami_changes` | bool   | `false`                                                                 | Whether to ignore AMI changes |

---

### Networking

| Name                          | Type         | Default | Description                                       |
| ----------------------------- | ------------ | ------- | ------------------------------------------------- |
| `subnet_id`                   | string       | `null`  | VPC Subnet ID                                     |
| `associate_public_ip_address` | bool         | `null`  | Assign a public IP address                        |
| `private_ip`                  | string       | `null`  | Static private IP                                 |
| `ipv6_address_count`          | number       | `null`  | Number of IPv6 addresses                          |
| `ipv6_addresses`              | list(string) | `null`  | Custom IPv6 addresses                             |
| `source_dest_check`           | bool         | `null`  | Enable/disable source/dest check (needed for NAT) |
| `enable_primary_ipv6`         | bool         | `null`  | Assign a primary IPv6 GUA when in dual-stack/IPv6-only subnets. |
| `network_interface`           | map(object)  | `null`  | Attach pre-existing ENIs or define advanced NIC configuration.  |
| `secondary_private_ips`       | list(string) | `null`  | List of secondary IPv4 addresses for eth0.                      |
| `placement_group`             | string       | `null`  | Launch instance into a Placement Group.                         |
| `placement_partition_number`  | number       | `null`  | Partition number (if Placement Group strategy is `partition`).  |
| `private_dns_name_options`    | object       | `null`  | Customize private DNS name records for the instance.            |
| `vpc_security_group_ids`      | list(string) | `[]`    | List of SG IDs to associate with instead of creating a new SG.  |

---

### Instance Settings

| Name                                   | Type   | Default    | Description                              |
| -------------------------------------- | ------ | ---------- | ---------------------------------------- |
| `instance_type`                        | string | `t3.micro` | EC2 instance type                        |
| `availability_zone`                    | string | `null`     | Specific AZ to launch in                 |
| `disable_api_termination`              | bool   | `null`     | Enable termination protection            |
| `disable_api_stop`                     | bool   | `null`     | Enable stop protection                   |
| `monitoring`                           | bool   | `null`     | Enable detailed monitoring               |
| `instance_initiated_shutdown_behavior` | string | `null`     | Shutdown behavior (stop/terminate)       |
| `hibernation`                          | bool   | `null`     | Enable hibernation                       |
| `tenancy`                              | string | `null`     | Tenancy (`default`, `dedicated`, `host`) |

---

### Capacity & CPU

| Name                                 | Type   | Default | Description                                                        |
| ------------------------------------ | ------ | ------- | ------------------------------------------------------------------ |
| `capacity_reservation_specification` | object | `null`  | Target a specific EC2 Capacity Reservation or group.               |
| `cpu_credits`                        | string | `null`  | Credit option for T2/T3/T4g instances (`standard` or `unlimited`). |
| `cpu_options`                        | object | `null`  | Configure CPU core count and threads per core.                     |

---

### Storage

| Name                     | Type        | Default | Description                   |
| ------------------------ | ----------- | ------- | ----------------------------- |
| `root_block_device`      | object      | `null`  | Customize root volume         |
| `ebs_optimized`          | bool        | `null`  | Launch EBS-optimized          |
| `ebs_volumes`            | map(object) | `null`  | Additional EBS volumes        |
| `ephemeral_block_device` | map(object) | `null`  | Instance store volumes        |
| `volume_tags`            | map(string) | `{}`    | Tags for attached volumes     |
| `enable_volume_tags`     | bool        | `true`  | Whether to enable volume tags |

---

### IAM

| Name                            | Type        | Default | Description                   |
| ------------------------------- | ----------- | ------- | ----------------------------- |
| `create_iam_instance_profile`   | bool        | `false` | Whether to create IAM profile |
| `iam_instance_profile`          | string      | `null`  | Existing IAM profile name     |
| `iam_role_name`                 | string      | `null`  | IAM role name                 |
| `iam_role_description`          | string      | `null`  | IAM role description          |
| `iam_role_path`                 | string      | `null`  | IAM role path                 |
| `iam_role_use_name_prefix`      | bool        | `true`  | Use name prefix for IAM role  |
| `iam_role_permissions_boundary` | string      | `null`  | IAM role boundary policy ARN  |
| `iam_role_policies`             | map(string) | `{}`    | IAM policies to attach        |
| `iam_role_tags`                 | map(string) | `{}`    | Tags for IAM role             |
| `existing_iam_role_name`        | string | `null` | If set, wrapper will create an instance profile from this existing role via `modules/instance-profile-from-role` and pass it to the child EC2 module. This implicitly disables `create_iam_instance_profile` for that instance. |

---

### Security Groups

| Name                             | Type        | Default   | Description            |
| -------------------------------- | ----------- | --------- | ---------------------- |
| `create_security_group`          | bool        | `true`    | Whether to create SG   |
| `security_group_name`            | string      | `null`    | SG name                |
| `security_group_description`     | string      | `null`    | SG description         |
| `security_group_vpc_id`          | string      | `null`    | VPC ID for SG          |
| `security_group_use_name_prefix` | bool        | `true`    | Use prefix for SG name |
| `security_group_tags`            | map(string) | `{}`      | Tags for SG            |
| `security_group_ingress_rules`   | map(object) | `null`    | Ingress rules          |
| `security_group_egress_rules`    | map(object) | Allow all | Egress rules           |

---


### Host & Enclave

| Name                      | Type   | Default | Description                                                                                   |
| ------------------------- | ------ | ------- | --------------------------------------------------------------------------------------------- |
| `enclave_options_enabled` | bool   | `null`  | Enable [Nitro Enclaves](https://docs.aws.amazon.com/enclaves/latest/user/nitro-enclave.html). |
| `host_id`                 | string | `null`  | ID of dedicated host to pin the instance to.                                                  |
| `host_resource_group_arn` | string | `null`  | ARN of host resource group (mutually exclusive with tenancy).                                 |

---

### Launch Templates & Market Options

| Name                      | Type   | Default | Description                                                                   |
| ------------------------- | ------ | ------- | ----------------------------------------------------------------------------- |
| `launch_template`         | object | `null`  | Specify a Launch Template (ID, Name, Version). Overrides conflicting inputs.  |
| `instance_market_options` | object | `null`  | Define instance purchasing market options (spot, capacity reservation, etc.). |

---

### Metadata & Maintenance

| Name                  | Type   | Default                                                                                    | Description                                          |
| --------------------- | ------ | ------------------------------------------------------------------------------------------ | ---------------------------------------------------- |
| `maintenance_options` | object | `null`                                                                                     | Instance auto-recovery settings.                     |
| `metadata_options`    | object | `{ http_endpoint = "enabled", http_put_response_hop_limit = 1, http_tokens = "required" }` | Configure IMDS (Instance Metadata Service) settings. |

Also forwarded:

- `region` (string, default `null`): Region to use for resources
- `enable_primary_ipv6` (bool, default `null`): Assign a primary IPv6 GUA on dual-stack/IPv6-only subnets

---

### Spot Instances

| Name                                  | Type   | Default | Description                                              |
| ------------------------------------- | ------ | ------- | -------------------------------------------------------- |
| `create_spot_instance`                | bool   | `false` | Launch as spot instance                                  |
| `spot_price`                          | string | `null`  | Max spot price                                           |
| `spot_type`                           | string | `null`  | `one-time` or `persistent`                               |
| `spot_instance_interruption_behavior` | string | `null`  | Interruption behavior (`terminate`, `stop`, `hibernate`) |
| `spot_wait_for_fulfillment`           | bool   | `null`  | Wait until request fulfilled                             |
| `spot_valid_from`                     | string | `null`  | Start time for request                                   |
| `spot_valid_until`                    | string | `null`  | End time for request                                     |
| `spot_launch_group`                   | string | `null`  | Spot launch group name                                   |

---

### Elastic IP

| Name         | Type        | Default | Description              |
| ------------ | ----------- | ------- | ------------------------ |
| `create_eip` | bool        | `false` | Create and associate EIP |
| `eip_domain` | string      | `"vpc"` | EIP domain               |
| `eip_tags`   | map(string) | `{}`    | Tags for EIP             |

---

### User Data

| Name                          | Type   | Default | Description                        |
| ----------------------------- | ------ | ------- | ---------------------------------- |
| `user_data`                   | string | `null`  | User data script                   |
| `user_data_base64`            | string | `null`  | Base64 user data                   |
| `user_data_replace_on_change` | bool   | `null`  | Force recreate on user data change |


---

### Miscellaneous

| Name                | Type        | Default | Description                                                      |
| ------------------- | ----------- | ------- | ---------------------------------------------------------------- |
| `get_password_data` | bool        | `null`  | Retrieve Windows admin password via EC2 metadata (Windows only). |
| `tags`              | map(string) | `{}`    | Tags applied to the instance resource.                           |
| `timeouts`          | map(string) | `{}`    | Custom timeouts for create/update/delete.                        |
| `key_name`     | The key name of the Key Pair to use for the instance; if not specified, no key will be attached                | `string`      | `null`       |    no    |
| `instance_tags` | Additional tags to assign **only** to the EC2 instance (not propagated to other resources like SGs or volumes) | `map(string)` | `{}`         |    no    |

---

## Additional Variables

| Name                                 | Description                                                                                                    | Type                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | Default                                                                                                                                                                                                                        | Required |
| ------------------------------------ | -------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ | :------: |
| capacity\_reservation\_specification | Describes an instance's Capacity Reservation targeting option                                                  | <pre>object({<br>  capacity\_reservation\_preference = optional(string)<br>  capacity\_reservation\_target = optional(object({<br>    capacity\_reservation\_id                 = optional(string)<br>    capacity\_reservation\_resource\_group\_arn = optional(string)<br>  }))<br>})</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                | `null`                                                                                                                                                                                                                         |    no    |
| cpu\_options                         | Defines CPU options to apply to the instance at launch time                                                    | <pre>object({<br>  amd\_sev\_snp      = optional(string)<br>  core\_count       = optional(number)<br>  threads\_per\_core = optional(number)<br>})</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `null`                                                                                                                                                                                                                         |    no    |
| ephemeral\_block\_device             | Customize Ephemeral (Instance Store) volumes on the instance                                                   | <pre>map(object({<br>  device\_name  = string<br>  no\_device    = optional(bool)<br>  virtual\_name = optional(string)<br>}))</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                         | `null`                                                                                                                                                                                                                         |    no    |
| instance\_market\_options            | The market (purchasing) option for the instance. If set, overrides the `create_spot_instance` variable         | <pre>object({<br>  market\_type = optional(string)<br>  spot\_options = optional(object({<br>    instance\_interruption\_behavior = optional(string)<br>    max\_price                      = optional(string)<br>    spot\_instance\_type             = optional(string)<br>    valid\_until                    = optional(string)<br>  }))<br>})</pre>                                                                                                                                                                                                                                                                                                                                                                                                     | `null`                                                                                                                                                                                                                         |    no    |
| launch\_template                     | Specifies a Launch Template to configure the instance. Parameters configured here override the Launch Template | <pre>object({<br>  id      = optional(string)<br>  name    = optional(string)<br>  version = optional(string)<br>})</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `null`                                                                                                                                                                                                                         |    no    |
| metadata\_options                    | Customize the metadata options of the instance                                                                 | <pre>object({<br>  http\_endpoint               = optional(string, "enabled")<br>  http\_protocol\_ipv6          = optional(string)<br>  http\_put\_response\_hop\_limit = optional(number, 1)<br>  http\_tokens                 = optional(string, "required")<br>  instance\_metadata\_tags      = optional(string)<br>})</pre>                                                                                                                                                                                                                                                                                                                                                                                                                            | <pre>{<br>  http\_endpoint = "enabled"<br>  http\_put\_response\_hop\_limit = 1<br>  http\_tokens = "required"<br>}</pre>                                                                                                      |    no    |
| network\_interface                   | Customize network interfaces to be attached at instance boot time                                              | <pre>map(object({<br>  delete\_on\_termination = optional(bool)<br>  device\_index          = optional(number)<br>  network\_card\_index    = optional(number)<br>  network\_interface\_id  = string<br>}))</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            | `null`                                                                                                                                                                                                                         |    no    |
| private\_dns\_name\_options          | Customize the private DNS name options of the instance                                                         | <pre>object({<br>  enable\_resource\_name\_dns\_a\_record    = optional(bool)<br>  enable\_resource\_name\_dns\_aaaa\_record = optional(bool)<br>  hostname\_type                        = optional(string)<br>})</pre>                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                      | `null`                                                                                                                                                                                                                         |    no    |
| root\_block\_device                  | Customize details about the root block device of the instance                                                  | <pre>object({<br>  delete\_on\_termination = optional(bool)<br>  encrypted             = optional(bool)<br>  iops                  = optional(number)<br>  kms\_key\_id            = optional(string)<br>  tags                  = optional(map(string))<br>  throughput            = optional(number)<br>  size                  = optional(number)<br>  type                  = optional(string)<br>})</pre>                                                                                                                                                                                                                                                                                                                                               | `null`                                                                                                                                                                                                                         |    no    |
| ebs\_volumes                         | Additional EBS volumes to attach to the instance                                                               | <pre>map(object({<br>  encrypted            = optional(bool)<br>  final\_snapshot       = optional(bool)<br>  iops                 = optional(number)<br>  kms\_key\_id           = optional(string)<br>  multi\_attach\_enabled = optional(bool)<br>  outpost\_arn          = optional(string)<br>  size                 = optional(number)<br>  snapshot\_id          = optional(string)<br>  tags                 = optional(map(string), {})<br>  throughput           = optional(number)<br>  type                 = optional(string, "gp3")<br>  device\_name          = optional(string)<br>  force\_detach         = optional(bool)<br>  skip\_destroy         = optional(bool)<br>  stop\_instance\_before\_detaching = optional(bool)<br>}))</pre> | `null`                                                                                                                                                                                                                         |    no    |
| security\_group\_egress\_rules       | Egress rules to add to the security group                                                                      | <pre>map(object({<br>  cidr\_ipv4                    = optional(string)<br>  cidr\_ipv6                    = optional(string)<br>  description                  = optional(string)<br>  from\_port                    = optional(number)<br>  ip\_protocol                  = optional(string, "tcp")<br>  prefix\_list\_id               = optional(string)<br>  referenced\_security\_group\_id = optional(string)<br>  tags                         = optional(map(string), {})<br>  to\_port                      = optional(number)<br>}))</pre>                                                                                                                                                                                                        | <pre>{<br>  ipv4\_default = { cidr\_ipv4="0.0.0.0/0", description="Allow all IPv4 traffic", ip\_protocol="-1" }<br>  ipv6\_default = { cidr\_ipv6="::/0", description="Allow all IPv6 traffic", ip\_protocol="-1" }<br>}</pre> |    no    |
| security\_group\_ingress\_rules      | Ingress rules to add to the security group                                                                     | <pre>map(object({<br>  cidr\_ipv4                    = optional(string)<br>  cidr\_ipv6                    = optional(string)<br>  description                  = optional(string)<br>  from\_port                    = optional(number)<br>  ip\_protocol                  = optional(string, "tcp")<br>  prefix\_list\_id               = optional(string)<br>  referenced\_security\_group\_id = optional(string)<br>  tags                         = optional(map(string), {})<br>  to\_port                      = optional(number)<br>}))</pre>                                                                                                                                                                                                        | `null`                                                                                                                                                                                                                         |    no    |


---

## Outputs

You can extend this wrapper to output attributes such as:

* Instance ID(s)
* Public IP(s)
* Private IP(s)
* Security Group IDs
* IAM Role names

---

## Example Terraform.tfvars

```hcl
defaults = {
  key_name      = "my-default-key"
  instance_type = "t3.micro"
  subnet_id     = "subnet-abc123"
}

ec2instance = {
  app = {
    name          = "app-server"
    instance_type = "t3.small"
    user_data     = file("app-init.sh")
  }

  db = {
    name          = "db-server"
    instance_type = "t3.medium"
    ebs_volumes = {
      data = {
        size        = 50
        type        = "gp3"
        device_name = "/dev/sdh"
      }
    }
  }

  spot = {
    name                 = "spot-worker"
    instance_type        = "t3.large"
    create_spot_instance = true
    spot_price           = "0.02"
  }

  # Example: use existing IAM role and let wrapper create an instance profile from it
  with_existing_role = {
    name                    = "web-with-existing-role"
    existing_iam_role_name  = "my-existing-ec2-role"
    # create_iam_instance_profile will be ignored/forced false for this item
  }
}
```

---

## How it works (flow)

1. You pass two inputs to the wrapper:
   - `defaults` (global baseline)
   - `ec2instance` (map of instances with per-item overrides)
2. For each `ec2instance["<name>"]` item:
   - If `existing_iam_role_name` is set:
     - Wrapper invokes child `modules/instance-profile-from-role` to create an `aws_iam_instance_profile` from that existing role.
     - The created profile name is fed into the base EC2 module input `iam_instance_profile`.
     - `create_iam_instance_profile` is forced to `false` for that item so the EC2 base module does not create another role/profile.
   - Else:
     - Wrapper forwards inputs to the base EC2 module. You may either:
       - Set `create_iam_instance_profile = true` to have the base module create role and profile, or
       - Provide `iam_instance_profile` to use an already-existing profile.
   - All other inputs (e.g., `region`, networking, storage, SG rules, spot options) are forwarded with `each.value` overriding `defaults`.
3. Wrapper outputs map to all child module outputs by key (e.g., `module.ec2_wrapper.wrapper["app"].id`).

### Scenarios

- Use base module to create role/profile:
  - Set `create_iam_instance_profile = true`.
  - Do not set `existing_iam_role_name`.

- Use an existing instance profile directly:
  - Set `iam_instance_profile = "existing-profile-name"`.
  - Do not set `create_iam_instance_profile` or `existing_iam_role_name`.

- Use an existing IAM role and let wrapper create an instance profile from it:
  - Set `existing_iam_role_name = "my-existing-ec2-role"`.
  - Wrapper creates the profile via the helper module and supplies it to EC2.
  - No role is created in this path, only an instance profile that points to your role.
