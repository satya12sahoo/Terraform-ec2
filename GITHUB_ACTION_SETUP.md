# GitHub Action Setup Guide

This guide explains how to set up and use the GitHub Action for deploying EC2 instances using the wrapper module with SSM access.

## 🚀 Quick Setup

### 1. Configure GitHub Secrets

First, you need to add your AWS credentials as GitHub repository secrets:

1. Go to your GitHub repository
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Add the following secrets:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | Your AWS Access Key ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `AWS_REGION` | Your AWS Region | `us-west-2` |

### 2. Create User Input Directory

The GitHub Action expects a user input directory. You can either:

- Use the existing `user-inputs` directory
- Create a new directory with your custom name
- Use environment-specific directories like `user-inputs/environments/dev`

### 3. Configure Your Terraform Variables

Create or modify `terraform.tfvars` in your chosen directory:

```hcl
# AWS Configuration
aws_region = "us-west-2"

# Project Configuration
environment  = "development"
project_name = "my-project"

# Security Group Configuration
create_security_group = true
security_group_name = "ec2-security-group"
security_group_description = "Security group for EC2 instances"
security_group_vpc_id = "vpc-your-vpc-id"  # Replace with your VPC ID

# IAM Configuration
create_iam_role = true
iam_role_name = "ec2-ssm-role"
iam_role_description = "IAM role for EC2 instances with SSM access"

# Instance configurations
instances = {
  web_server = {
    name                        = "web-server"
    ami                         = "ami-0c02fb55956c7d316"
    instance_type              = "t3.micro"
    availability_zone          = "us-west-2a"
    subnet_id                  = "subnet-a65c14eb"
    associate_public_ip_address = true
    
    root_block_device = {
      size       = 20
      type       = "gp3"
      encrypted  = true
      throughput = 125
    }
    
    tags = {
      Name = "web-server"
      Role = "web"
      Environment = "development"
    }
  }
}

# Security Group Rules
security_group_ingress_rules = {
  http = {
    description = "HTTP access"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  https = {
    description = "HTTPS access"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ssh = {
    description = "SSH access"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

security_group_egress_rules = {
  all_outbound = {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

### 4. Run the GitHub Action

1. Go to the **Actions** tab in your repository
2. Select **Deploy EC2 Instances** workflow
3. Click **Run workflow**
4. Configure the inputs:

| Input | Description | Default | Required |
|-------|-------------|---------|----------|
| `user_input_directory` | Directory containing your tfvars files | `user-inputs` | Yes |
| `terraform_action` | Action to perform: plan, apply, or destroy | `plan` | Yes |
| `auto_approve` | Auto-approve terraform changes | `false` | No |

## 📋 Detailed Configuration

### AWS Credentials Setup

#### Option 1: IAM User (Recommended for Development)

1. Create an IAM user with the following permissions:
```json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
                "ec2:*",
                "iam:*",
                "cloudwatch:*",
                "s3:*",
                "ssm:*",
                "sns:*"
            ],
            "Resource": "*"
        }
    ]
}
```

2. Generate access keys for the user
3. Add the keys to GitHub secrets

#### Option 2: IAM Role (Recommended for Production)

1. Create an IAM role with the necessary permissions
2. Configure GitHub Actions to assume the role using OIDC
3. Update the workflow to use role assumption

### Required AWS Resources

Before running the action, ensure you have:

1. **VPC and Subnets**:
   - VPC with appropriate CIDR blocks
   - Public and private subnets in your chosen availability zones
   - Internet Gateway and NAT Gateway (if needed)

2. **Subnet ID**: 
   - The action is configured to use `subnet-a65c14eb` by default
   - Update this in your `terraform.tfvars` if needed

3. **VPC ID**:
   - Required for security group creation
   - Replace `vpc-your-vpc-id` with your actual VPC ID

### Key Features

#### 🔐 SSM-Based Access
- **No SSH keys required**: All instances use AWS Systems Manager for secure access
- **Automatic IAM roles**: Created with SSM permissions
- **Secure by default**: IMDSv2 enabled, encrypted volumes

#### 🛡️ Security Groups
- **Automatically created**: With names from your tfvars configuration
- **Configurable rules**: HTTP, HTTPS, SSH access defined in tfvars
- **Environment-specific**: Different security groups for dev/prod

#### 👤 IAM Roles
- **SSM permissions**: `AmazonSSMManagedInstanceCore` policy attached
- **Customizable names**: Set via `iam_role_name` in tfvars
- **Instance profiles**: Automatically created and attached

### Example AWS Resource IDs

Replace these placeholder values in your `terraform.tfvars`:

```hcl
# Example values - replace with your actual IDs
security_group_vpc_id = "vpc-1234567890abcdef0"
subnet_id = "subnet-a65c14eb"  # Already set correctly
```

## 🔧 Workflow Features

### Supported Actions

1. **Plan**: Preview changes without applying them
2. **Apply**: Deploy the infrastructure
3. **Destroy**: Remove the infrastructure

### Environment-Specific Deployments

You can create different configurations for different environments:

```
user-inputs/
├── environments/
│   ├── dev/
│   │   └── terraform.tfvars    # Development configuration
│   ├── staging/
│   │   └── terraform.tfvars    # Staging configuration
│   └── prod/
│       └── terraform.tfvars    # Production configuration
```

To deploy to a specific environment:
- Set `user_input_directory` to `user-inputs/environments/dev`
- Or `user-inputs/environments/prod` for production

### User Data Templates

The action supports user data templates for instance initialization:

1. **Create a template** in `templates/user_data.sh`
2. **Reference it** in your configuration:
```hcl
enable_user_data_template = true
user_data_template_path = "templates/user_data.sh"
user_data_template_vars = {
  hostname = "web-server"
  role     = "web"
  environment = "development"
}
```

### Monitoring and Logging

Enable monitoring and logging modules:

```hcl
# Enable monitoring
enable_monitoring_module = true
monitoring = {
  cloudwatch_agent_role_name = "cloudwatch-agent-role"
  dashboard_name = "ec2-monitoring-dashboard"
  # ... more configuration
}

# Enable logging
enable_logging_module = true
logging = {
  create_s3_logging_bucket = true
  s3_logging_bucket_name = "my-logs-bucket"
  # ... more configuration
}
```

## 🔒 Security Best Practices

### 1. IAM Permissions

Use the principle of least privilege:
- Only grant necessary permissions
- Use IAM roles instead of access keys when possible
- Regularly rotate credentials

### 2. Network Security

- Use private subnets for application servers
- Configure security groups with minimal required access
- Enable VPC Flow Logs for network monitoring

### 3. Instance Security

- Enable IMDSv2 (metadata options)
- Use encrypted EBS volumes
- Enable CloudWatch monitoring
- Use SSM for secure access (no SSH keys)

### 4. Secrets Management

- Store sensitive data in AWS Secrets Manager or Parameter Store
- Never commit secrets to version control
- Use GitHub secrets for CI/CD credentials

## 🔐 SSM Access Guide

### Connecting to Instances

Once your instances are deployed, you can connect using AWS Systems Manager:

#### AWS CLI
```bash
# Get instance ID
aws ec2 describe-instances --filters "Name=tag:Name,Values=web-server" --query "Reservations[].Instances[].InstanceId" --output text

# Connect via SSM
aws ssm start-session --target <instance-id>
```

#### AWS Console
1. Go to EC2 → Instances
2. Select your instance
3. Click "Connect"
4. Choose "Session Manager"
5. Click "Connect"

### SSM Prerequisites

Ensure your AWS account has:
- Systems Manager service enabled
- VPC endpoints for SSM (if using private subnets)
- Proper IAM permissions for SSM

## 🚨 Troubleshooting

### Common Issues

1. **AWS Credentials Error**:
   - Verify GitHub secrets are correctly set
   - Check IAM permissions
   - Ensure region matches your resources

2. **Terraform Validation Errors**:
   - Check your `terraform.tfvars` syntax
   - Verify all required variables are set
   - Review the wrapper module documentation

3. **Resource Creation Failures**:
   - Check AWS service limits
   - Verify VPC ID and subnet ID
   - Review CloudTrail logs for detailed error messages

4. **SSM Connection Issues**:
   - Verify IAM role has SSM permissions
   - Check VPC endpoints if using private subnets
   - Ensure Systems Manager service is enabled

### Debugging Steps

1. **Run with Plan First**:
   - Always run `plan` before `apply`
   - Review the plan output carefully

2. **Check Action Logs**:
   - Review the GitHub Action logs for detailed error messages
   - Look for specific Terraform error messages

3. **Verify AWS Resources**:
   - Check AWS Console for existing resources
   - Verify resource IDs and configurations

### Getting Help

1. **Check the wrapper module documentation**: `wrapper/README.md`
2. **Review example configurations**: `user-inputs/terraform.tfvars.example`
3. **Check GitHub Action logs** for specific error messages
4. **Review AWS CloudTrail** for API call failures

## 📚 Additional Resources

- [Wrapper Module Documentation](wrapper/README.md)
- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS EC2 Documentation](https://docs.aws.amazon.com/ec2/)
- [AWS SSM Documentation](https://docs.aws.amazon.com/systems-manager/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [AWS IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)

## 🔄 Workflow Lifecycle

### Typical Deployment Process

1. **Development**:
   - Create configuration in `user-inputs/environments/dev/`
   - Run `plan` to validate
   - Run `apply` to deploy

2. **Testing**:
   - Test the deployed infrastructure
   - Verify application functionality
   - Check monitoring and logging
   - Test SSM connectivity

3. **Production**:
   - Create configuration in `user-inputs/environments/prod/`
   - Run `plan` for review
   - Run `apply` with approval

4. **Cleanup**:
   - Run `destroy` when resources are no longer needed
   - Verify all resources are removed

### Continuous Integration

Consider integrating this workflow into your CI/CD pipeline:

- Trigger on pull requests for `plan`
- Trigger on merge to main for `apply`
- Use branch protection rules for production deployments
- Implement approval workflows for production changes