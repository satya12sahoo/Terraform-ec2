# EC2 Instance Deployment with GitHub Actions

This directory contains the Terraform configuration and GitHub Actions workflow for deploying EC2 instances using the wrapper module.

## Overview

The deployment system consists of:
- **GitHub Actions Workflow**: Automated deployment pipeline
- **Terraform Configuration**: Infrastructure as Code using the wrapper module
- **Environment-specific Configurations**: Separate configurations for dev, staging, and production

## Prerequisites

### 1. AWS Setup
- AWS account with appropriate permissions
- AWS credentials configured in GitHub Secrets
- VPC, subnets, and security groups created
- Key pairs created for SSH access

### 2. GitHub Repository Setup
- Repository with the wrapper module
- GitHub Secrets configured (see below)
- Environment protection rules configured (optional but recommended)

### 3. Required GitHub Secrets

Configure the following secrets in your GitHub repository:

| Secret Name | Description | Example |
|-------------|-------------|---------|
| `AWS_ACCESS_KEY_ID` | AWS Access Key ID | `AKIAIOSFODNN7EXAMPLE` |
| `AWS_SECRET_ACCESS_KEY` | AWS Secret Access Key | `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY` |
| `TF_STATE_BUCKET` | S3 bucket for Terraform state | `my-terraform-state-bucket` |
| `TF_LOCK_TABLE` | DynamoDB table for state locking | `terraform-lock-table` |

### 4. Environment Configuration

Set up environment protection rules in GitHub:
1. Go to Settings → Environments
2. Create environments: `dev`, `staging`, `production`
3. Configure protection rules as needed
4. Add required reviewers for production deployments

## Configuration Files

### Main Terraform Files
- `main.tf` - Main Terraform configuration using the wrapper module
- `variables.tf` - Input variable definitions
- `outputs.tf` - Output values from the deployment

### Environment Configurations
- `instances.tfvars` - Default configuration (development)
- `staging.tfvars` - Staging environment configuration
- `production.tfvars` - Production environment configuration

## Usage

### 1. Automated Deployment (Recommended)

The GitHub Actions workflow automatically deploys when:
- Code is pushed to `main` branch
- Pull requests are created/updated
- Manual workflow dispatch is triggered

#### Manual Deployment
1. Go to Actions tab in GitHub
2. Select "Deploy EC2 Instances" workflow
3. Click "Run workflow"
4. Configure:
   - **Environment**: `dev`, `staging`, or `production`
   - **Action**: `plan`, `apply`, or `destroy`
   - **Instance configuration**: Path to `.tfvars` file (optional)

### 2. Local Development

For local development and testing:

```bash
# Navigate to terraform directory
cd terraform

# Initialize Terraform
terraform init

# Plan deployment
terraform plan -var-file="instances.tfvars"

# Apply deployment
terraform apply -var-file="instances.tfvars"

# Destroy resources
terraform destroy -var-file="instances.tfvars"
```

## Configuration Examples

### Basic Web Server
```hcl
instances = {
  web_server = {
    name                        = "web-server"
    ami                         = "ami-0c02fb55956c7d316"
    instance_type              = "t3.micro"
    availability_zone          = "us-west-2a"
    subnet_id                  = "subnet-1234567890abcdef0"
    vpc_security_group_ids     = ["sg-1234567890abcdef0"]
    associate_public_ip_address = true
    key_name                   = "my-key-pair"
    
    root_block_device = {
      size       = 20
      type       = "gp3"
      encrypted  = true
      throughput = 125
    }
    
    tags = {
      Name        = "web-server"
      Role        = "web"
      Environment = "dev"
    }
  }
}
```

### Production Database Server
```hcl
instances = {
  db_server = {
    name                        = "db-server"
    ami                         = "ami-0c02fb55956c7d316"
    instance_type              = "t3.large"
    availability_zone          = "us-west-2a"
    subnet_id                  = "subnet-1234567890abcdef0"
    vpc_security_group_ids     = ["sg-1234567890abcdef0"]
    associate_public_ip_address = false
    key_name                   = "prod-key-pair"
    
    root_block_device = {
      size       = 100
      type       = "gp3"
      encrypted  = true
      throughput = 300
    }
    
    ebs_volumes = {
      data_volume = {
        size       = 500
        type       = "gp3"
        encrypted  = true
        throughput = 300
      }
    }
    
    disable_api_termination = true
    monitoring             = true
    
    create_iam_instance_profile = true
    iam_role_policies          = {
      cloudwatch = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
    }
    
    tags = {
      Name        = "db-server"
      Role        = "database"
      Environment = "production"
      Critical    = "true"
    }
  }
}
```

## Security Best Practices

### 1. Network Security
- Use private subnets for database servers
- Configure security groups with minimal required access
- Enable VPC Flow Logs for monitoring

### 2. Instance Security
- Use encrypted EBS volumes
- Enable IMDSv2 with required tokens
- Use IAM roles instead of access keys
- Enable CloudWatch monitoring

### 3. Access Control
- Use key pairs for SSH access
- Implement least privilege IAM policies
- Enable termination protection for production instances

## Monitoring and Logging

### CloudWatch Integration
The configuration includes CloudWatch monitoring by default:
- Basic monitoring enabled
- CloudWatch Agent policy attached (when IAM profiles are created)
- Custom metrics can be added via user data

### Logging
- CloudTrail logs all API calls
- VPC Flow Logs track network traffic
- CloudWatch Logs for application logs

## Troubleshooting

### Common Issues

1. **AMI Not Found**
   - Verify AMI ID exists in the target region
   - Use SSM parameter for latest AMI: `/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64`

2. **Subnet/Security Group Not Found**
   - Verify resource IDs exist in the target region
   - Check VPC configuration

3. **Key Pair Not Found**
   - Create key pair in AWS console or CLI
   - Verify key pair name matches configuration

4. **Insufficient Permissions**
   - Verify IAM user/role has required permissions
   - Check GitHub Secrets configuration

### Debugging Workflow

1. Check workflow logs in GitHub Actions
2. Verify environment secrets are configured
3. Test Terraform commands locally
4. Check AWS CloudTrail for API errors

## Cost Optimization

### Instance Types
- Use `t3.micro` for development
- Use `t3.small/medium` for staging
- Use appropriate instance types for production workloads

### Storage
- Use GP3 volumes for better performance/cost ratio
- Right-size EBS volumes
- Enable EBS optimization for larger instances

### Scheduling
- Use AWS Instance Scheduler for non-production environments
- Implement auto-scaling for production workloads

## Support

For issues and questions:
1. Check the wrapper module documentation
2. Review GitHub Actions logs
3. Consult AWS documentation
4. Create an issue in the repository

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the same license as the main repository.