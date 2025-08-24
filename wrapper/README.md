# EC2 Instance Wrapper

This wrapper provides a flexible way to create multiple EC2 instances using Terraform with explicit configurations and no default values. It uses a `for_each` loop to create instances with different configurations based on their roles.

## Features

- **No Default Values**: All configurations are explicit, ensuring predictable deployments
- **Loop-based Creation**: Uses `for_each` to create multiple instances with different configurations
- **Role-based Configuration**: Each instance can have different configurations based on its role
- **Override Support**: Easy to override configurations for specific instances
- **Comprehensive Outputs**: Provides detailed information about created instances

## Instance Types

The wrapper creates the following instances by default:

1. **web_server_1** (t3.micro) - Web server in AZ 1
2. **web_server_2** (t3.small) - Web server in AZ 2  
3. **app_server_1** (t3.medium) - Application server in AZ 1
4. **db_server_1** (t3.large) - Database server in AZ 3

## Usage

### 1. Copy the example configuration

```bash
cp terraform.tfvars.example terraform.tfvars
```

### 2. Update the configuration

Edit `terraform.tfvars` with your specific values:

```hcl
aws_region = "us-west-2"
environment = "production"
project_name = "my-application"

# Network configuration
availability_zones = ["us-west-2a", "us-west-2b", "us-west-2c"]
subnet_ids = ["subnet-xxx", "subnet-yyy", "subnet-zzz"]
security_group_ids = ["sg-xxx"]

# AMI and key pair
ami_id = "ami-0c02fb55956c7d316"
key_pair_name = "my-key-pair"
```

### 3. Initialize and apply

```bash
terraform init
terraform plan
terraform apply
```

## Customizing Instance Configurations

### Adding New Instances

To add new instances, modify the `instance_configs` local variable in `main.tf`:

```hcl
locals {
  instance_configs = {
    # ... existing instances ...
    
    new_server = {
      name                        = "new-server"
      ami                         = var.ami_id
      instance_type              = "t3.xlarge"
      availability_zone          = var.availability_zones[0]
      subnet_id                  = var.subnet_ids[0]
      vpc_security_group_ids     = var.security_group_ids
      associate_public_ip_address = false
      key_name                   = var.key_pair_name
      user_data                  = base64encode(templatefile("${path.module}/templates/user_data.sh", {
        hostname = "new-server"
        role     = "custom"
      }))
      root_block_device = {
        size       = 100
        type       = "gp3"
        encrypted  = true
        throughput = 125
        tags = {
          Name = "new-server-root"
        }
      }
      tags = {
        Name     = "new-server"
        Role     = "custom"
        Environment = var.environment
        Project  = var.project_name
      }
    }
  }
}
```

### Modifying Existing Instances

To modify existing instances, update their configuration in the `instance_configs` map:

```hcl
web_server_1 = {
  name                        = "web-server-1"
  ami                         = var.ami_id
  instance_type              = "t3.small"  # Changed from t3.micro
  # ... rest of configuration
}
```

### Conditional Instance Creation

You can conditionally create instances based on variables:

```hcl
locals {
  base_configs = {
    web_server_1 = {
      # ... configuration
    }
    app_server_1 = {
      # ... configuration  
    }
  }
  
  # Only create database server in production
  db_configs = var.environment == "production" ? {
    db_server_1 = {
      # ... database configuration
    }
  } : {}
  
  instance_configs = merge(local.base_configs, local.db_configs)
}
```

## User Data Templates

The wrapper uses a template-based approach for user data. The template file `templates/user_data.sh` supports role-based configuration:

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

## Outputs

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
```

## Security Considerations

- All instances use encrypted EBS volumes
- IMDSv2 is enabled with required tokens
- Security groups should be configured appropriately
- Key pairs should be managed securely
- Consider using IAM roles for instance permissions

## Cost Optimization

- Use appropriate instance types for workloads
- Consider using Spot instances for non-critical workloads
- Monitor and adjust EBS volumes as needed
- Use appropriate storage types (gp3 for general purpose)

## Troubleshooting

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

## Contributing

To add new features or configurations:

1. Update the `instance_configs` in `main.tf`
2. Add corresponding variables in `variables.tf`
3. Update outputs in `outputs.tf` if needed
4. Update the user data template if adding new roles
5. Update this README with new features