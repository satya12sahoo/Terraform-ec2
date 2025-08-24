# EC2 Instance Wrapper - Dynamic Configuration

This wrapper provides a **completely dynamic** way to create multiple EC2 instances using Terraform. **All configurations come from tfvars** - there are no hardcoded values in the wrapper itself. It uses a `for_each` loop to create instances with configurations that are entirely driven by user input.

## 🎯 Key Features

- **✅ Zero Hardcoded Values**: Everything is configurable from tfvars
- **🔄 Dynamic Loop-based Creation**: Uses `for_each` with user-defined configurations
- **⚙️ Flexible Configuration**: Each instance can have completely different settings
- **🏷️ Role-based Templates**: User data templates support role-based configuration
- **🌍 Global Settings**: Optional global settings that can override instance-specific configs
- **📊 Comprehensive Outputs**: Detailed information about created instances
- **🔧 Full Base Module Support**: All variables from the base EC2 module are available

## 📁 Structure

```
wrapper/
├── main.tf                    # Dynamic configuration processing
├── variables.tf               # Variable definitions (all base module variables included)
├── outputs.tf                 # Comprehensive outputs
├── versions.tf                # Terraform version requirements
├── README.md                  # This documentation
├── terraform.tfvars.example   # Example configuration
├── templates/
│   └── user_data.sh          # Role-based user data template
└── examples/
    ├── simple-usage.tf        # Basic usage example
    └── advanced-dynamic.tf    # Advanced dynamic configuration
```

## 🚀 Usage

### 1. Copy the example configuration

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Define your instance configurations

Edit `terraform.tfvars` with your specific instance configurations:

```hcl
# Basic settings
aws_region = "us-west-2"
environment = "production"
project_name = "my-application"

# Instance configurations - everything defined here
instances = {
  web_server_1 = {
    name                        = "web-server-1"
    ami                         = "ami-0c02fb55956c7d316"
    instance_type              = "t3.micro"
    availability_zone          = "us-west-2a"
    subnet_id                  = "subnet-1234567890abcdef0"
    vpc_security_group_ids     = ["sg-1234567890abcdef0"]
    associate_public_ip_address = true
    key_name                   = "my-key-pair"
    
    # User data template variables
    user_data_template_vars = {
      hostname = "web-server-1"
      role     = "web"
    }
    
    # Root block device
    root_block_device = {
      size       = 20
      type       = "gp3"
      encrypted  = true
      throughput = 125
      tags = {
        Name = "web-server-1-root"
      }
    }
    
    # Tags
    tags = {
      Name = "web-server-1"
      Role = "web"
    }
  }
  
  # Add more instances as needed...
}
```

### 3. Initialize and apply

```bash
terraform init
terraform plan
terraform apply
```

## 📋 Configuration Options

### Instance Configuration Structure

Each instance in the `instances` map supports the following configuration:

```hcl
instance_name = {
  # Required fields
  name                        = string
  ami                         = string
  instance_type              = string
  availability_zone          = string
  subnet_id                  = string
  vpc_security_group_ids     = list(string)
  associate_public_ip_address = bool
  key_name                   = string
  
  # User data configuration
  user_data_template_vars = map(string)  # Variables for template
  
  # Block device configuration
  root_block_device = {
    size       = number
    type       = string
    encrypted  = bool
    throughput = optional(number, 125)
    tags       = optional(map(string), {})
  }
  
  # EBS volumes (optional)
  ebs_volumes = {
    "/dev/sdf" = {
      size       = number
      type       = string
      encrypted  = bool
      throughput = optional(number, 125)
      tags       = optional(map(string), {})
    }
  }
  
  # Instance settings
  disable_api_stop       = optional(bool, false)
  disable_api_termination = optional(bool, false)
  ebs_optimized          = optional(bool, true)
  monitoring             = optional(bool, true)
  
  # IAM configuration
  create_iam_instance_profile = optional(bool, false)
  iam_role_policies          = optional(map(string), {})
  
  # Metadata options
  metadata_options = {
    http_endpoint               = optional(string, "enabled")
    http_tokens                 = optional(string, "required")
    http_put_response_hop_limit = optional(number, 1)
    instance_metadata_tags      = optional(string, "enabled")
  }
  
  # Tags
  tags = map(string)
}
```

### Global Settings

Optional global settings that can override instance-specific configurations:

```hcl
global_settings = {
  enable_monitoring = optional(bool, true)
  enable_ebs_optimization = optional(bool, true)
  enable_termination_protection = optional(bool, false)
  enable_stop_protection = optional(bool, false)
  create_iam_profiles = optional(bool, false)
  iam_role_policies = optional(map(string), {})
  additional_tags = optional(map(string), {})
}
```

## 🔧 All Available Variables

The wrapper exposes **ALL variables** from the base EC2 module. Here are the key categories:

### Basic Configuration
- `create` - Whether to create instances
- `region` - AWS region
- `environment` - Environment name
- `project_name` - Project name

### Instance Configuration
- `ami_ssm_parameter` - SSM parameter for AMI
- `ignore_ami_changes` - Ignore AMI changes
- `capacity_reservation_specification` - Capacity reservation settings
- `cpu_options` - CPU configuration
- `cpu_credits` - CPU credits for T instances
- `enclave_options_enabled` - Nitro Enclaves
- `enable_primary_ipv6` - IPv6 support
- `ephemeral_block_device` - Instance store volumes
- `get_password_data` - Get Windows password
- `hibernation` - Instance hibernation
- `host_id` - Dedicated host ID
- `host_resource_group_arn` - Host resource group
- `instance_initiated_shutdown_behavior` - Shutdown behavior
- `instance_market_options` - Spot instance options
- `ipv6_address_count` - IPv6 address count
- `ipv6_addresses` - IPv6 addresses
- `launch_template` - Launch template
- `maintenance_options` - Maintenance options
- `network_interface` - Network interfaces
- `placement_group` - Placement group
- `placement_partition_number` - Partition number
- `private_dns_name_options` - Private DNS options
- `private_ip` - Private IP address
- `secondary_private_ips` - Secondary private IPs
- `source_dest_check` - Source/destination check
- `tenancy` - Instance tenancy

### User Data & Storage
- `user_data` - User data script
- `user_data_base64` - Base64 encoded user data
- `user_data_replace_on_change` - Replace on change
- `enable_volume_tags` - Enable volume tags
- `volume_tags` - Volume tags
- `timeouts` - Operation timeouts

### Spot Instance Configuration
- `create_spot_instance` - Create spot instance
- `spot_instance_interruption_behavior` - Interruption behavior
- `spot_launch_group` - Launch group
- `spot_price` - Maximum price
- `spot_type` - Spot type
- `spot_wait_for_fulfillment` - Wait for fulfillment
- `spot_valid_from` - Valid from date
- `spot_valid_until` - Valid until date

### IAM Configuration
- `iam_role_name` - IAM role name
- `iam_role_use_name_prefix` - Use name prefix
- `iam_role_path` - IAM role path
- `iam_role_description` - Role description
- `iam_role_permissions_boundary` - Permissions boundary
- `iam_role_tags` - IAM role tags
- `iam_instance_profile` - Existing IAM profile
- `existing_iam_role_name` - Name of existing IAM role to create instance profile for
- `create_instance_profile_for_existing_role` - Whether to create instance profile for existing role
- `instance_profile_name` - Custom name for the instance profile
- `instance_profile_use_name_prefix` - Use name prefix for instance profile
- `instance_profile_path` - Instance profile path
- `instance_profile_tags` - Instance profile tags
- `enable_smart_iam` - Enable smart IAM feature (Google-like)
- `smart_iam_role_name` - Name for role/instance profile in smart mode
- `smart_iam_role_description` - Description for IAM role in smart mode
- `smart_iam_role_path` - IAM role path in smart mode
- `smart_iam_role_policies` - Policies for IAM role in smart mode
- `smart_iam_role_permissions_boundary` - Permissions boundary in smart mode
- `smart_iam_role_tags` - Tags for IAM role in smart mode
- `smart_instance_profile_tags` - Tags for instance profile in smart mode
- `smart_iam_force_create_role` - Force role creation even if instance profile exists

### Security Group Configuration
- `create_security_group` - Create security group
- `security_group_name` - Security group name
- `security_group_use_name_prefix` - Use name prefix
- `security_group_description` - Description
- `security_group_vpc_id` - VPC ID
- `security_group_tags` - Security group tags
- `security_group_egress_rules` - Egress rules
- `security_group_ingress_rules` - Ingress rules

### Elastic IP Configuration
- `create_eip` - Create Elastic IP
- `eip_domain` - EIP domain
- `eip_tags` - EIP tags

### Additional Configuration
- `instance_tags` - Additional instance tags
- `putin_khuylo` - Required variable

## 🔧 Advanced Usage Examples

### Simple Configuration

```hcl
instances = {
  web_server = {
    name                        = "web-server"
    ami                         = "ami-0c02fb55956c7d316"
    instance_type              = "t3.micro"
    availability_zone          = "us-west-2a"
    subnet_id                  = "subnet-xxx"
    vpc_security_group_ids     = ["sg-xxx"]
    associate_public_ip_address = true
    key_name                   = "my-key-pair"
    
    user_data_template_vars = {
      hostname = "web-server"
      role     = "web"
    }
    
    root_block_device = {
      size       = 20
      type       = "gp3"
      encrypted  = true
      throughput = 125
    }
    
    tags = {
      Name = "web-server"
      Role = "web"
    }
  }
}
```

### Complex Configuration with Advanced Features

```hcl
instances = {
  database_server = {
    name                        = "db-server"
    ami                         = "ami-0c02fb55956c7d316"
    instance_type              = "t3.large"
    availability_zone          = "us-west-2c"
    subnet_id                  = "subnet-xxx"
    vpc_security_group_ids     = ["sg-xxx"]
    associate_public_ip_address = false
    key_name                   = "my-key-pair"
    
    user_data_template_vars = {
      hostname = "db-server"
      role     = "database"
    }
    
    root_block_device = {
      size       = 100
      type       = "gp3"
      encrypted  = true
      throughput = 125
    }
    
    ebs_volumes = {
      "/dev/sdf" = {
        size       = 500
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "db-data"
          MountPoint = "/mnt/database"
        }
      }
      "/dev/sdg" = {
        size       = 200
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "db-backup"
          MountPoint = "/mnt/backup"
        }
      }
    }
    
    disable_api_stop       = true
    disable_api_termination = true
    
    tags = {
      Name = "db-server"
      Role = "database"
    }
  }
}

# Global advanced configuration
cpu_options = {
  core_count       = 2
  threads_per_core = 1
}

cpu_credits = "unlimited"
hibernation = false
instance_initiated_shutdown_behavior = "stop"

# IAM configuration
create_iam_instance_profile = true
iam_role_policies = {
  "S3ReadOnly" = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  "CloudWatchAgent" = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Security group configuration
create_security_group = true
security_group_ingress_rules = {
  ssh = {
    from_port   = 22
    to_port     = 22
    ip_protocol = "tcp"
    cidr_ipv4   = "10.0.0.0/8"
    description = "SSH access"
  }
  http = {
    from_port   = 80
    to_port     = 80
    ip_protocol = "tcp"
    cidr_ipv4   = "0.0.0.0/0"
    description = "HTTP access"
  }
}

# Elastic IP configuration
create_eip = true
eip_tags = {
  Name = "database-eip"
}
```

### Spot Instance Configuration

```hcl
# Spot instance configuration
create_spot_instance = true
spot_instance_interruption_behavior = "stop"
spot_price = "0.05"
spot_type = "persistent"
spot_wait_for_fulfillment = true

instances = {
  spot_worker = {
    name                        = "spot-worker"
    ami                         = "ami-0c02fb55956c7d316"
    instance_type              = "t3.micro"
    availability_zone          = "us-west-2a"
    subnet_id                  = "subnet-xxx"
    vpc_security_group_ids     = ["sg-xxx"]
    associate_public_ip_address = false
    key_name                   = "my-key-pair"
    
    user_data_template_vars = {
      hostname = "spot-worker"
      role     = "worker"
    }
    
    root_block_device = {
      size       = 20
      type       = "gp3"
      encrypted  = true
      throughput = 125
    }
    
    tags = {
      Name = "spot-worker"
      Role = "worker"
      SpotInstance = "true"
    }
  }
}
```

### IAM Instance Profile for Existing Role

The wrapper can create an IAM instance profile for an existing IAM role. This is useful when you have an existing IAM role but need to create an instance profile for EC2 instances to use it.

```hcl
# IAM Instance Profile for existing role configuration
create_instance_profile_for_existing_role = true
existing_iam_role_name = "my-existing-ec2-role"  # Your existing IAM role name
instance_profile_name = "my-ec2-instance-profile"  # Optional: custom name for instance profile
instance_profile_use_name_prefix = true
instance_profile_path = "/"
instance_profile_tags = {
  Purpose = "EC2 Instance Profile"
  CreatedBy = "Terraform"
  Environment = "production"
}

# Instance configurations (set create_iam_instance_profile = false to use the created profile)
instances = {
  web_server = {
    name                        = "web-server"
    ami                         = "ami-0c02fb55956c7d316"
    instance_type              = "t3.micro"
    availability_zone          = "us-west-2a"
    subnet_id                  = "subnet-xxx"
    vpc_security_group_ids     = ["sg-xxx"]
    associate_public_ip_address = true
    key_name                   = "my-key-pair"
    
    user_data_template_vars = {
      hostname = "web-server"
      role     = "web"
    }
    
    root_block_device = {
      size       = 20
      type       = "gp3"
      encrypted  = true
      throughput = 125
    }
    
    create_iam_instance_profile = false  # Use the created instance profile
    iam_role_policies          = {}
    
    tags = {
      Name = "web-server"
      Role = "web"
    }
  }
}
```

**Outputs for IAM Instance Profile:**
```bash
# Get the created instance profile ARN
terraform output iam_instance_profile_arn

# Get the instance profile name
terraform output iam_instance_profile_name

# Get the existing IAM role ARN
terraform output existing_iam_role_arn
```

**How it works:**
1. The wrapper uses a data source to fetch the existing IAM role
2. Creates an IAM instance profile that references the existing role
3. All instances will use this instance profile automatically
4. The instance profile is tagged and managed by Terraform

**Prerequisites:**
- The IAM role must already exist in your AWS account
- The IAM role must have a trust policy that allows EC2 instances to assume it
- You must have permissions to create IAM instance profiles

**Example IAM Role Trust Policy:**
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

### Dynamic Configuration Generation

See `examples/advanced-dynamic.tf` for an example that shows how to:
- Use data sources to get AMIs, subnets, and security groups
- Generate configurations based on environment
- Scale instances dynamically
- Use conditional logic for different environments

## 🏷️ User Data Templates

The wrapper supports role-based user data templates. The template file `templates/user_data.sh` supports:

- **web**: Installs Apache, PHP, and configures web server
- **application**: Installs Java, Tomcat, and configures application server
- **database**: Installs MySQL and configures database server

### Customizing User Data

To add new roles or modify existing ones, edit `templates/user_data.sh`:

```bash
case "${role}" in
    "web")
        # Web server configuration
        ;;
    "application") 
        # Application server configuration
        ;;
    "database")
        # Database server configuration
        ;;
    "custom")
        # Custom role configuration
        yum install -y custom-package
        ;;
esac
```

## 📊 Outputs

The wrapper provides comprehensive outputs:

```bash
# Get all instance IDs
terraform output instance_ids

# Get private IPs
terraform output instance_private_ips

# Get instances by role
terraform output instances_by_role

# Get total instance count
terraform output total_instances

# Get instance configurations
terraform output instance_configurations
```

## 🔒 Security Considerations

- All instances use encrypted EBS volumes by default
- IMDSv2 is enabled with required tokens
- Security groups should be configured appropriately
- Key pairs should be managed securely
- Consider using IAM roles for instance permissions

## 💰 Cost Optimization

- Use appropriate instance types for workloads
- Consider using Spot instances for non-critical workloads
- Monitor and adjust EBS volumes as needed
- Use appropriate storage types (gp3 for general purpose)

## 🛠️ Troubleshooting

### Common Issues

1. **AMI not found**: Ensure the AMI ID is valid for your region
2. **Subnet not found**: Verify subnet IDs and availability zones
3. **Security group not found**: Check security group IDs and permissions
4. **Key pair not found**: Ensure the key pair exists in the specified region

### Debugging

Enable Terraform debug output:

```bash
export TF_LOG=DEBUG
terraform apply
```

Check instance logs:

```bash
# SSH to instance and check logs
sudo tail -f /var/log/app/init.log
sudo tail -f /var/log/cloud-init-output.log
```

## 🤝 Contributing

To add new features or configurations:

1. Update the variable definitions in `variables.tf`
2. Update the processing logic in `main.tf` if needed
3. Update outputs in `outputs.tf` if needed
4. Update the user data template if adding new roles
5. Update this README with new features
6. Add examples in the `examples/` directory

## 📝 License

This wrapper is provided as-is for educational and production use.