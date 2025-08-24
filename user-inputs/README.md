# User Input Directory

This directory contains your Terraform configuration files for deploying EC2 instances using the wrapper module.

## 📁 Directory Structure

```
user-inputs/
├── README.md                    # This file
├── terraform.tfvars            # Your main configuration file
├── terraform.tfvars.example    # Example configuration
├── environments/               # Environment-specific configurations
│   ├── dev/
│   │   └── terraform.tfvars
│   ├── staging/
│   │   └── terraform.tfvars
│   └── prod/
│       └── terraform.tfvars
└── templates/                  # User data templates (optional)
    └── user_data.sh
```

## 🚀 Quick Start

1. **Configure your AWS credentials** in GitHub repository secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`
   - `AWS_REGION`

2. **Create your configuration** by editing `terraform.tfvars`:
   ```hcl
   # AWS Configuration
   aws_region = "us-west-2"
   
   # Project Configuration
   environment  = "development"
   project_name = "my-project"
   
   # Instance configurations
   instances = {
     web_server = {
       name                        = "web-server"
       ami                         = "ami-0c02fb55956c7d316"
       instance_type              = "t3.micro"
       availability_zone          = "us-west-2a"
       subnet_id                  = "subnet-your-subnet-id"
       vpc_security_group_ids     = ["sg-your-security-group-id"]
       associate_public_ip_address = true
       key_name                   = "your-key-pair"
       
       # ... more configuration
     }
   }
   ```

3. **Run the GitHub Action**:
   - Go to Actions tab in your repository
   - Select "Deploy EC2 Instances" workflow
   - Click "Run workflow"
   - Set the user input directory to `user-inputs`
   - Choose action: `plan`, `apply`, or `destroy`

## 📋 Required Configuration

### Essential Variables

| Variable | Description | Example |
|----------|-------------|---------|
| `aws_region` | AWS region for deployment | `"us-west-2"` |
| `environment` | Environment name | `"development"` |
| `project_name` | Project name for tagging | `"my-project"` |
| `instances` | Map of instance configurations | See examples below |

### Instance Configuration

Each instance in the `instances` map requires:

```hcl
instances = {
  instance_name = {
    name                        = "instance-name"
    ami                         = "ami-id"
    instance_type              = "t3.micro"
    availability_zone          = "us-west-2a"
    subnet_id                  = "subnet-id"
    vpc_security_group_ids     = ["sg-id"]
    associate_public_ip_address = true
    key_name                   = "key-pair-name"
    
    root_block_device = {
      size       = 20
      type       = "gp3"
      encrypted  = true
      throughput = 125
    }
    
    tags = {
      Name = "instance-name"
      Role = "web"
    }
  }
}
```

## 🔧 Environment-Specific Configurations

You can create environment-specific configurations:

1. **Create environment directories**:
   ```bash
   mkdir -p environments/{dev,staging,prod}
   ```

2. **Copy and customize configurations**:
   ```bash
   cp terraform.tfvars environments/dev/
   cp terraform.tfvars environments/staging/
   cp terraform.tfvars environments/prod/
   ```

3. **Run with specific environment**:
   - Set user input directory to `user-inputs/environments/dev`
   - Or `user-inputs/environments/prod` for production

## 📝 User Data Templates

You can use template files for user data:

1. **Create template file**:
   ```bash
   mkdir -p templates
   ```

2. **Create user data template** (`templates/user_data.sh`):
   ```bash
   #!/bin/bash
   yum update -y
   yum install -y httpd
   systemctl start httpd
   systemctl enable httpd
   echo "Hello from ${hostname}" > /var/www/html/index.html
   ```

3. **Reference in configuration**:
   ```hcl
   instances = {
     web_server = {
       # ... other config
       user_data_template_vars = {
         hostname = "web-server"
         role     = "web"
       }
     }
   }
   ```

## 🔒 Security Best Practices

1. **Use IAM roles** instead of hardcoded credentials
2. **Enable encryption** for EBS volumes
3. **Use security groups** to restrict access
4. **Enable IMDSv2** (metadata options)
5. **Use key pairs** for SSH access

## 🚨 Important Notes

- **Replace placeholder values** in the example configurations
- **Test with plan first** before applying
- **Backup your configurations** before making changes
- **Use version control** for your configuration files
- **Review security groups** and network access

## 📚 Additional Resources

- [Wrapper Module Documentation](../wrapper/README.md)
- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)