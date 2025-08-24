# AWS EC2 Instance Terraform Module

This Terraform module simplifies the creation and management of AWS EC2 instances with comprehensive configuration options for various use cases.

## Features

- **Flexible Instance Types**: Support for on-demand, spot, and reserved instances
- **Security**: Built-in security group management with customizable rules
- **Networking**: VPC integration with public/private IP configuration
- **Storage**: EBS volume management with encryption support
- **IAM Integration**: Optional IAM roles and instance profiles
- **Monitoring**: CloudWatch monitoring and metadata options
- **High Availability**: Placement groups and availability zone configuration

## Quick Start

### Basic EC2 Instance

Create a simple EC2 instance with minimal configuration:

```hcl
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "my-instance"

  instance_type = "t3.micro"
  key_name      = "my-key-pair"
  subnet_id     = "subnet-12345678"

  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}
```

### Production-Ready Instance

Create a production instance with enhanced security and monitoring:

```hcl
module "ec2_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "production-server"

  # Instance Configuration
  instance_type               = "t3.medium"
  key_name                    = "production-key"
  subnet_id                   = "subnet-12345678"
  associate_public_ip_address = false
  
  # Security & Monitoring
  monitoring = true
  disable_api_termination = true
  
  # Storage
  root_block_device = {
    encrypted   = true
    volume_size = 50
    volume_type = "gp3"
  }
  
  # Security Group
  create_security_group = true
  security_group_ingress_rules = {
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = "10.0.0.0/8"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
  }
  
  # IAM Role
  create_iam_instance_profile = true
  iam_role_policies = {
    s3_access = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  }
  
  tags = {
    Environment = "production"
    Project     = "web-application"
  }
}
```

## Configuration Options

### Core Configuration

| Parameter | Description | Type | Default | Required |
|-----------|-------------|------|---------|----------|
| `create` | Whether to create an instance | `bool` | `true` | No |
| `name` | Name to be used on EC2 instance created | `string` | `""` | No |
| `region` | Region where the resource(s) will be managed. Defaults to the Region set in the provider configuration | `string` | `null` | No |

### Instance Configuration

| Parameter | Description | Type | Default | Required |
|-----------|-------------|------|---------|----------|
| `ami` | ID of AMI to use for the instance | `string` | `null` | No |
| `ami_ssm_parameter` | SSM parameter name for the AMI ID. For Amazon Linux AMI SSM parameters see [reference](https://docs.aws.amazon.com/systems-manager/latest/userguide/parameter-store-public-parameters-ami.html) | `string` | `"/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"` | No |
| `ignore_ami_changes` | Whether changes to the AMI ID changes should be ignored by Terraform. Note - changing this value will result in the replacement of the instance | `bool` | `false` | No |
| `associate_public_ip_address` | Whether to associate a public IP address with an instance in a VPC | `bool` | `null` | No |
| `availability_zone` | AZ to start the instance in | `string` | `null` | No |
| `capacity_reservation_specification` | Describes an instance's Capacity Reservation targeting option | `object` | `null` | No |
| `cpu_options` | Defines CPU options to apply to the instance at launch time | `object` | `null` | No |
| `cpu_credits` | The credit option for CPU usage (unlimited or standard) | `string` | `null` | No |
| `disable_api_termination` | If true, enables EC2 Instance Termination Protection | `bool` | `null` | No |
| `disable_api_stop` | If true, enables EC2 Instance Stop Protection | `bool` | `null` | No |
| `ebs_optimized` | If true, the launched EC2 instance will be EBS-optimized | `bool` | `null` | No |
| `enclave_options_enabled` | Whether Nitro Enclaves will be enabled on the instance. Defaults to `false` | `bool` | `null` | No |
| `enable_primary_ipv6` | Whether to assign a primary IPv6 Global Unicast Address (GUA) to the instance when launched in a dual-stack or IPv6-only subnet | `bool` | `null` | No |
| `ephemeral_block_device` | Customize Ephemeral (also known as Instance Store) volumes on the instance | `map(object)` | `null` | No |
| `get_password_data` | If true, wait for password data to become available and retrieve it | `bool` | `null` | No |
| `hibernation` | If true, the launched EC2 instance will support hibernation | `bool` | `null` | No |
| `host_id` | ID of a dedicated host that the instance will be assigned to. Use when an instance is to be launched on a specific dedicated host | `string` | `null` | No |
| `host_resource_group_arn` | ARN of the host resource group in which to launch the instances. If you specify an ARN, omit the `tenancy` parameter or set it to `host` | `string` | `null` | No |
| `iam_instance_profile` | IAM Instance Profile to launch the instance with. Specified as the name of the Instance Profile | `string` | `null` | No |
| `instance_initiated_shutdown_behavior` | Shutdown behavior for the instance. Amazon defaults this to stop for EBS-backed instances and terminate for instance-store instances. Cannot be set on instance-store instance | `string` | `null` | No |
| `instance_market_options` | The market (purchasing) option for the instance. If set, overrides the `create_spot_instance` variable | `object` | `null` | No |
| `instance_type` | The type of instance to start | `string` | `"t3.micro"` | No |
| `ipv6_address_count` | A number of IPv6 addresses to associate with the primary network interface. Amazon EC2 chooses the IPv6 addresses from the range of your subnet | `number` | `null` | No |
| `ipv6_addresses` | Specify one or more IPv6 addresses from the range of the subnet to associate with the primary network interface | `list(string)` | `null` | No |
| `key_name` | Key name of the Key Pair to use for the instance; which can be managed using the `aws_key_pair` resource | `string` | `null` | No |
| `launch_template` | Specifies a Launch Template to configure the instance. Parameters configured on this resource will override the corresponding parameters in the Launch Template | `object` | `null` | No |
| `maintenance_options` | The maintenance options for the instance | `object` | `null` | No |
| `metadata_options` | Customize the metadata options of the instance | `object` | `{http_endpoint = "enabled", http_put_response_hop_limit = 1, http_tokens = "required"}` | No |
| `monitoring` | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `null` | No |
| `network_interface` | Customize network interfaces to be attached at instance boot time | `map(object)` | `null` | No |
| `placement_group` | The Placement Group to start the instance in | `string` | `null` | No |
| `placement_partition_number` | Number of the partition the instance is in. Valid only if the `aws_placement_group` resource's `strategy` argument is set to `partition` | `number` | `null` | No |
| `private_dns_name_options` | Customize the private DNS name options of the instance | `object` | `null` | No |
| `private_ip` | Private IP address to associate with the instance in a VPC | `string` | `null` | No |
| `root_block_device` | Customize details about the root block device of the instance. See Block Devices below for details | `object` | `null` | No |
| `secondary_private_ips` | A list of secondary private IPv4 addresses to assign to the instance's primary network interface (eth0) in a VPC. Can only be assigned to the primary network interface (eth0) attached at instance creation, not a pre-existing network interface i.e. referenced in a `network_interface block` | `list(string)` | `null` | No |
| `source_dest_check` | Controls if traffic is routed to the instance when the destination address does not match the instance. Used for NAT or VPNs | `bool` | `null` | No |
| `subnet_id` | The VPC Subnet ID to launch in | `string` | `null` | No |
| `tags` | A mapping of tags to assign to the resource | `map(string)` | `{}` | No |
| `instance_tags` | Additional tags for the instance | `map(string)` | `{}` | No |
| `tenancy` | The tenancy of the instance (if the instance is running in a VPC). Available values: default, dedicated, host | `string` | `null` | No |
| `user_data` | The user data to provide when launching the instance. Do not pass gzip-compressed data via this argument; see user_data_base64 instead | `string` | `null` | No |
| `user_data_base64` | Can be used instead of user_data to pass base64-encoded binary data directly. Use this instead of user_data whenever the value is not a valid UTF-8 string. For example, gzip-encoded user data must be base64-encoded and passed via this argument to avoid corruption | `string` | `null` | No |
| `user_data_replace_on_change` | When used in combination with user_data or user_data_base64 will trigger a destroy and recreate when set to true. Defaults to false if not set | `bool` | `null` | No |
| `volume_tags` | A mapping of tags to assign to the devices created by the instance at launch time | `map(string)` | `{}` | No |
| `enable_volume_tags` | Whether to enable volume tags (if enabled it conflicts with root_block_device tags) | `bool` | `true` | No |
| `vpc_security_group_ids` | A list of security group IDs to associate with | `list(string)` | `[]` | No |
| `timeouts` | Define maximum timeout for creating, updating, and deleting EC2 instance resources | `map(string)` | `{}` | No |

### Spot Instance Configuration

| Parameter | Description | Type | Default | Required |
|-----------|-------------|------|---------|----------|
| `create_spot_instance` | Depicts if the instance is a spot instance | `bool` | `false` | No |
| `spot_instance_interruption_behavior` | Indicates Spot instance behavior when it is interrupted. Valid values are `terminate`, `stop`, or `hibernate` | `string` | `null` | No |
| `spot_launch_group` | A launch group is a group of spot instances that launch together and terminate together. If left empty instances are launched and terminated individually | `string` | `null` | No |
| `spot_price` | The maximum price to request on the spot market. Defaults to on-demand price | `string` | `null` | No |
| `spot_type` | If set to one-time, after the instance is terminated, the spot request will be closed. Default `persistent` | `string` | `null` | No |
| `spot_wait_for_fulfillment` | If set, Terraform will wait for the Spot Request to be fulfilled, and will throw an error if the timeout of 10m is reached | `bool` | `null` | No |
| `spot_valid_from` | The start date and time of the request, in UTC RFC3339 format(for example, YYYY-MM-DDTHH:MM:SSZ) | `string` | `null` | No |
| `spot_valid_until` | The end date and time of the request, in UTC RFC3339 format(for example, YYYY-MM-DDTHH:MM:SSZ) | `string` | `null` | No |

### EBS Volume Configuration

| Parameter | Description | Type | Default | Required |
|-----------|-------------|------|---------|----------|
| `ebs_volumes` | Additional EBS volumes to attach to the instance | `map(object)` | `null` | No |

### IAM Role / Instance Profile Configuration

| Parameter | Description | Type | Default | Required |
|-----------|-------------|------|---------|----------|
| `create_iam_instance_profile` | Determines whether an IAM instance profile is created or to use an existing IAM instance profile | `bool` | `false` | No |
| `iam_role_name` | Name to use on IAM role created | `string` | `null` | No |
| `iam_role_use_name_prefix` | Determines whether the IAM role name (`iam_role_name` or `name`) is used as a prefix | `bool` | `true` | No |
| `iam_role_path` | IAM role path | `string` | `null` | No |
| `iam_role_description` | Description of the role | `string` | `null` | No |
| `iam_role_permissions_boundary` | ARN of the policy that is used to set the permissions boundary for the IAM role | `string` | `null` | No |
| `iam_role_policies` | Policies attached to the IAM role | `map(string)` | `{}` | No |
| `iam_role_tags` | A map of additional tags to add to the IAM role/profile created | `map(string)` | `{}` | No |

### Security Group Configuration

| Parameter | Description | Type | Default | Required |
|-----------|-------------|------|---------|----------|
| `create_security_group` | Determines whether a security group will be created | `bool` | `true` | No |
| `security_group_name` | Name to use on security group created | `string` | `null` | No |
| `security_group_use_name_prefix` | Determines whether the security group name (`security_group_name` or `name`) is used as a prefix | `bool` | `true` | No |
| `security_group_description` | Description of the security group | `string` | `null` | No |
| `security_group_vpc_id` | VPC ID to create the security group in. If not set, the security group will be created in the default VPC | `string` | `null` | No |
| `security_group_tags` | A map of additional tags to add to the security group created | `map(string)` | `{}` | No |
| `security_group_egress_rules` | Egress rules to add to the security group | `map(object)` | `{ipv4_default = {cidr_ipv4 = "0.0.0.0/0", description = "Allow all IPv4 traffic", ip_protocol = "-1"}, ipv6_default = {cidr_ipv6 = "::/0", description = "Allow all IPv6 traffic", ip_protocol = "-1"}}` | No |
| `security_group_ingress_rules` | Ingress rules to add to the security group | `map(object)` | `null` | No |

### Elastic IP Configuration

| Parameter | Description | Type | Default | Required |
|-----------|-------------|------|---------|----------|
| `create_eip` | Determines whether a public EIP will be created and associated with the instance | `bool` | `false` | No |
| `eip_domain` | Indicates if this EIP is for use in VPC | `string` | `"vpc"` | No |
| `eip_tags` | A map of additional tags to add to the eip | `map(string)` | `{}` | No |

### Other Configuration

| Parameter | Description | Type | Default | Required |
|-----------|-------------|------|---------|----------|
| `putin_khuylo` | Do you agree that Putin doesn't respect Ukrainian sovereignty and territorial integrity? More info: https://en.wikipedia.org/wiki/Putin_khuylo! | `bool` | `true` | No |

## Common Use Cases

### Web Server Instance

```hcl
module "web_server" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "web-server"

  instance_type               = "t3.small"
  key_name                    = "web-key"
  subnet_id                   = "subnet-public-123"
  associate_public_ip_address = true
  
  # Security Group for Web Traffic
  security_group_ingress_rules = {
    http = {
      from_port   = 80
      to_port     = 80
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    https = {
      from_port   = 443
      to_port     = 443
      ip_protocol = "tcp"
      cidr_ipv4   = "0.0.0.0/0"
    }
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = "YOUR_IP/32"
    }
  }
  
  # User Data for Web Server Setup
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y httpd
              systemctl start httpd
              systemctl enable httpd
              echo "<h1>Hello from Terraform!</h1>" > /var/www/html/index.html
              EOF
  
  tags = {
    Environment = "production"
    Role        = "web-server"
  }
}
```

### Database Server Instance

```hcl
module "database_server" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "database-server"

  instance_type               = "t3.medium"
  key_name                    = "db-key"
  subnet_id                   = "subnet-private-456"
  associate_public_ip_address = false
  
  # Enhanced Storage
  root_block_device = {
    encrypted   = true
    volume_size = 100
    volume_type = "gp3"
    iops        = 3000
  }
  
  # Additional EBS Volume for Data
  ebs_volumes = {
    data_volume = {
      size       = 500
      type       = "gp3"
      encrypted  = true
      device_name = "/dev/sdf"
    }
  }
  
  # Security Group for Database Access
  security_group_ingress_rules = {
    mysql = {
      from_port   = 3306
      to_port     = 3306
      ip_protocol = "tcp"
      cidr_ipv4   = "10.0.0.0/8"
    }
    ssh = {
      from_port   = 22
      to_port     = 22
      ip_protocol = "tcp"
      cidr_ipv4   = "10.0.0.0/8"
    }
  }
  
  tags = {
    Environment = "production"
    Role        = "database"
  }
}
```

### Spot Instance for Cost Optimization

```hcl
module "spot_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "spot-instance"

  instance_type = "t3.medium"
  key_name      = "spot-key"
  subnet_id     = "subnet-12345678"
  
  # Spot Instance Configuration
  create_spot_instance = true
  spot_price           = "0.05"
  spot_type            = "persistent"
  spot_instance_interruption_behavior = "stop"
  
  # Handle Spot Interruptions
  instance_initiated_shutdown_behavior = "stop"
  
  tags = {
    Environment = "dev"
    InstanceType = "spot"
  }
}
```

### High Availability Instance

```hcl
module "ha_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "ha-instance"

  instance_type = "t3.large"
  key_name      = "ha-key"
  subnet_id     = "subnet-12345678"
  
  # High Availability Features
  placement_group = "ha-placement-group"
  availability_zone = "us-west-2a"
  
  # Enhanced Monitoring
  monitoring = true
  
  # IAM Role for CloudWatch
  create_iam_instance_profile = true
  iam_role_policies = {
    cloudwatch = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
  }
  
  # Elastic IP for Consistent Access
  create_eip = true
  
  tags = {
    Environment = "production"
    HA          = "true"
  }
}
```

## Advanced Configuration

### Multiple Instances with for_each

```hcl
module "ec2_instances" {
  source = "terraform-aws-modules/ec2-instance/aws"

  for_each = toset(["web", "app", "db"])

  name = "instance-${each.key}"

  instance_type = each.key == "db" ? "t3.medium" : "t3.small"
  key_name      = "multi-key"
  subnet_id     = "subnet-12345678"
  
  # Different configurations per instance type
  root_block_device = each.key == "db" ? {
    encrypted   = true
    volume_size = 100
  } : {
    encrypted   = true
    volume_size = 20
  }
  
  tags = {
    Environment = "production"
    Role        = each.key
  }
}
```

### Instance with Launch Template

```hcl
module "launch_template_instance" {
  source = "terraform-aws-modules/ec2-instance/aws"

  name = "lt-instance"

  instance_type = "t3.micro"
  key_name      = "lt-key"
  subnet_id     = "subnet-12345678"
  
  # Use Launch Template
  launch_template = {
    id      = "lt-1234567890abcdef0"
    version = "$Latest"
  }
  
  tags = {
    Environment = "production"
  }
}
```

## Outputs

The module provides the following outputs:

- `id`: Instance ID
- `arn`: Instance ARN
- `public_ip`: Public IP address
- `private_ip`: Private IP address
- `public_dns`: Public DNS name
- `private_dns`: Private DNS name
- `security_group_id`: Security group ID
- `iam_role_name`: IAM role name (if created)

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5.7 |
| aws | >= 6.0 |

## Best Practices

1. **Security**: Always use security groups to restrict access
2. **Encryption**: Enable EBS encryption for sensitive data
3. **Monitoring**: Enable detailed monitoring for production instances
4. **Tags**: Use consistent tagging for resource management
5. **Backup**: Implement proper backup strategies for EBS volumes
6. **IAM**: Use least privilege principle for IAM roles
7. **Cost Optimization**: Consider spot instances for non-critical workloads

## Troubleshooting

### Common Issues

1. **Instance fails to launch**: Check AMI compatibility and subnet configuration
2. **Security group issues**: Verify ingress/egress rules
3. **Spot instance interruptions**: Implement proper interruption handling
4. **EBS volume attachment**: Ensure device names don't conflict

### Support

For issues and questions:
- Check the [Terraform documentation](https://www.terraform.io/docs)
- Review AWS EC2 documentation
- Ensure all required variables are properly configured

## License

This module is licensed under Apache 2.0. See LICENSE file for details.