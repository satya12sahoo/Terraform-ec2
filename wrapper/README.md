# EC2 Instance Wrapper - Dynamic Configuration

This wrapper provides a **completely dynamic** way to create multiple EC2 instances using Terraform. **All configurations come from tfvars** - there are no hardcoded values in the wrapper itself. It uses a `for_each` loop to create instances with configurations that are entirely driven by user input.

## 🎯 Key Features

- **✅ Zero Hardcoded Values**: Everything is configurable from tfvars
- **🔄 Dynamic Loop-based Creation**: Uses `for_each` with user-defined configurations
- **⚙️ Flexible Configuration**: Each instance can have completely different settings
- **🏷️ Role-based Templates**: User data templates support role-based configuration
- **🌍 Global Settings**: Optional global settings that can override instance-specific configs
- **📊 Comprehensive Outputs**: Detailed information about created instances

## 📁 Structure

```
wrapper/
├── main.tf                    # Dynamic configuration processing
├── variables.tf               # Variable definitions (no defaults)
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

### Complex Configuration with EBS Volumes

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