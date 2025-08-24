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

### Instance Configuration

| Parameter | Description | Default | Required |
|-----------|-------------|---------|----------|
| `name` | Name for the EC2 instance | `""` | Yes |
| `instance_type` | EC2 instance type | `"t3.micro"` | No |
| `ami` | AMI ID to use | `null` | No |
| `key_name` | SSH key pair name | `null` | No |
| `subnet_id` | VPC subnet ID | `null` | No |
| `availability_zone` | Availability zone | `null` | No |
| `private_ip` | Private IP address | `null` | No |
| `associate_public_ip_address` | Associate public IP | `null` | No |

### Security Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `create_security_group` | Create security group | `true` |
| `security_group_ingress_rules` | Inbound rules | `null` |
| `security_group_egress_rules` | Outbound rules | `{}` |
| `vpc_security_group_ids` | Existing security group IDs | `[]` |
| `disable_api_termination` | Termination protection | `null` |
| `disable_api_stop` | Stop protection | `null` |

### Storage Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `root_block_device` | Root volume configuration | `null` |
| `ebs_volumes` | Additional EBS volumes | `null` |
| `enable_volume_tags` | Enable volume tagging | `true` |

### IAM Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `create_iam_instance_profile` | Create IAM profile | `false` |
| `iam_role_policies` | IAM policies to attach | `{}` |
| `iam_role_name` | IAM role name | `null` |

### Spot Instance Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `create_spot_instance` | Create spot instance | `false` |
| `spot_price` | Maximum spot price | `null` |
| `spot_type` | Spot request type | `null` |
| `spot_instance_interruption_behavior` | Interruption behavior | `null` |

### Networking Configuration

| Parameter | Description | Default |
|-----------|-------------|---------|
| `network_interface` | Network interface config | `null` |
| `enable_primary_ipv6` | Enable IPv6 | `null` |
| `ipv6_address_count` | Number of IPv6 addresses | `null` |
| `create_eip` | Create Elastic IP | `false` |

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
