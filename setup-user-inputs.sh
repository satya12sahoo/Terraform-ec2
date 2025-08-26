#!/bin/bash

# Setup script for GitHub Action user inputs
# This script helps you quickly set up your user input directory

set -e

echo "🚀 Setting up GitHub Action user inputs..."

# Default values
DEFAULT_ENVIRONMENT="development"
DEFAULT_REGION="us-west-2"
DEFAULT_PROJECT="my-project"

# Get user input
read -p "Enter environment name [$DEFAULT_ENVIRONMENT]: " ENVIRONMENT
ENVIRONMENT=${ENVIRONMENT:-$DEFAULT_ENVIRONMENT}

read -p "Enter AWS region [$DEFAULT_REGION]: " REGION
REGION=${REGION:-$DEFAULT_REGION}

read -p "Enter project name [$DEFAULT_PROJECT]: " PROJECT
PROJECT=${PROJECT:-$DEFAULT_PROJECT}

read -p "Enter user input directory name [user-inputs]: " INPUT_DIR
INPUT_DIR=${INPUT_DIR:-user-inputs}

# Create directory structure
echo "📁 Creating directory structure..."
mkdir -p "$INPUT_DIR"
mkdir -p "$INPUT_DIR/environments/dev"
mkdir -p "$INPUT_DIR/environments/staging"
mkdir -p "$INPUT_DIR/environments/prod"
mkdir -p "$INPUT_DIR/templates"

# Create main.tf file to reference wrapper module
echo "📋 Creating main.tf file..."
cat > "$INPUT_DIR/main.tf" << 'EOF'
# Reference the wrapper module
module "ec2_wrapper" {
  source = "../wrapper"
  
  # Pass all variables from terraform.tfvars
  aws_region = var.aws_region
  environment = var.environment
  project_name = var.project_name
  instances = var.instances
  global_settings = var.global_settings
  
  # Security Group Configuration
  create_security_group = var.create_security_group
  security_group_name = var.security_group_name
  security_group_use_name_prefix = var.security_group_use_name_prefix
  security_group_description = var.security_group_description
  security_group_vpc_id = var.security_group_vpc_id
  security_group_ingress_rules = var.security_group_ingress_rules
  security_group_egress_rules = var.security_group_egress_rules
  
  # IAM Configuration
  iam_role_name = var.iam_role_name
  iam_role_use_name_prefix = var.iam_role_use_name_prefix
  iam_role_description = var.iam_role_description
  
  # Optional monitoring and logging
  enable_monitoring_module = var.enable_monitoring_module
  monitoring = var.monitoring
  enable_logging_module = var.enable_logging_module
  logging = var.logging
  
  # System tags configuration
  managed_by_tag = var.managed_by_tag
  feature_tag = var.feature_tag
  ec2_service_principal = var.ec2_service_principal
  assume_role_policy_version = var.assume_role_policy_version
  default_role_name = var.default_role_name
  
  # User data configuration
  enable_user_data_template = var.enable_user_data_template
  user_data_template_path = var.user_data_template_path
  user_data = var.user_data
  user_data_base64 = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change
}
EOF

# Create variables.tf file
echo "📋 Creating variables.tf file..."
cat > "$INPUT_DIR/variables.tf" << 'EOF'
# Variables for the wrapper module
variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
}

variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
}

variable "project_name" {
  description = "Project name for tagging"
  type        = string
}

variable "instances" {
  description = "Map of instance configurations"
  type        = any
}

variable "global_settings" {
  description = "Global settings that apply to all instances"
  type        = any
  default     = {}
}

# Security Group variables
variable "create_security_group" {
  description = "Determines whether a security group will be created"
  type        = bool
  default     = false
}

variable "security_group_name" {
  description = "Name to use on security group created"
  type        = string
  default     = null
}

variable "security_group_use_name_prefix" {
  description = "Determines whether the security group name is used as a prefix"
  type        = bool
  default     = true
}

variable "security_group_description" {
  description = "Description of the security group"
  type        = string
  default     = null
}

variable "security_group_vpc_id" {
  description = "VPC ID to create the security group in"
  type        = string
  default     = null
}

variable "security_group_ingress_rules" {
  description = "Ingress rules to add to the security group"
  type        = any
  default     = null
}

variable "security_group_egress_rules" {
  description = "Egress rules to add to the security group"
  type        = any
  default     = {}
}

# IAM variables
variable "iam_role_name" {
  description = "Name to use on IAM role created"
  type        = string
  default     = null
}

variable "iam_role_use_name_prefix" {
  description = "Determines whether the IAM role name is used as a prefix"
  type        = bool
  default     = true
}

variable "iam_role_description" {
  description = "Description of the role"
  type        = string
  default     = null
}

# Monitoring variables
variable "enable_monitoring_module" {
  description = "Enable monitoring module"
  type        = bool
  default     = false
}

variable "monitoring" {
  description = "Monitoring configuration"
  type        = any
  default     = {}
}

# Logging variables
variable "enable_logging_module" {
  description = "Enable logging module"
  type        = bool
  default     = false
}

variable "logging" {
  description = "Logging configuration"
  type        = any
  default     = {}
}

# System tags variables
variable "managed_by_tag" {
  description = "Managed by tag"
  type        = string
  default     = "terraform"
}

variable "feature_tag" {
  description = "Feature tag"
  type        = string
  default     = "adaptive-iam"
}

variable "ec2_service_principal" {
  description = "EC2 service principal"
  type        = string
  default     = "ec2.amazonaws.com"
}

variable "assume_role_policy_version" {
  description = "Assume role policy version"
  type        = string
  default     = "2012-10-17"
}

variable "default_role_name" {
  description = "Default role name"
  type        = string
  default     = "default"
}

# User data variables
variable "enable_user_data_template" {
  description = "Whether to use a user data template file"
  type        = bool
  default     = false
}

variable "user_data_template_path" {
  description = "Path to the user data template file"
  type        = string
  default     = null
}

variable "user_data" {
  description = "User data script"
  type        = string
  default     = null
}

variable "user_data_base64" {
  description = "User data script (base64 encoded)"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Whether to replace user data on change"
  type        = bool
  default     = false
}
EOF

# Create outputs.tf file
echo "📋 Creating outputs.tf file..."
cat > "$INPUT_DIR/outputs.tf" << 'EOF'
# Outputs from the wrapper module
output "instance_ids" {
  description = "List of instance IDs"
  value       = module.ec2_wrapper.instance_ids
}

output "instance_arns" {
  description = "List of instance ARNs"
  value       = module.ec2_wrapper.instance_arns
}

output "instance_public_ips" {
  description = "List of public IP addresses"
  value       = module.ec2_wrapper.instance_public_ips
}

output "instance_private_ips" {
  description = "List of private IP addresses"
  value       = module.ec2_wrapper.instance_private_ips
}

output "security_group_ids" {
  description = "List of security group IDs"
  value       = module.ec2_wrapper.security_group_ids
}

output "iam_role_arns" {
  description = "List of IAM role ARNs"
  value       = module.ec2_wrapper.iam_role_arns
}

output "iam_instance_profile_arns" {
  description = "List of IAM instance profile ARNs"
  value       = module.ec2_wrapper.iam_instance_profile_arns
}
EOF

# Create main terraform.tfvars
echo "⚙️ Creating main terraform.tfvars..."
cat > "$INPUT_DIR/terraform.tfvars" << EOF
# AWS Configuration
aws_region = "$REGION"

# Project Configuration
environment  = "$ENVIRONMENT"
project_name = "$PROJECT"

# Security Group Configuration
create_security_group = true
security_group_name = "security-group"
security_group_use_name_prefix = false
security_group_description = "Security group for EC2 instances"
security_group_vpc_id = "vpc-3d80a556"

# IAM Configuration
iam_role_name = "iam-role"
iam_role_use_name_prefix = false
iam_role_description = "IAM role for EC2 instances with SSM access"

# Instance configurations
instances = {
  web_server = {
    name                        = "web-server"
    ami                         = "ami-0c02fb55956c7d316"  # Amazon Linux 2023 AMI
    instance_type              = "t3.micro"
    availability_zone          = "${REGION}a"
    subnet_id                  = "subnet-a65c14eb"
    associate_public_ip_address = true
    
    # User data template variables
    user_data_template_vars = {
      hostname = "web-server"
      role     = "web"
      environment = "$ENVIRONMENT"
    }
    
    # Root block device
    root_block_device = {
      size       = 20
      type       = "gp3"
      encrypted  = true
      throughput = 125
      tags = {
        Name = "web-server-root"
        Environment = "$ENVIRONMENT"
      }
    }
    
    # Instance settings
    disable_api_stop       = false
    disable_api_termination = false
    ebs_optimized          = true
    monitoring             = true
    
    # IAM configuration - will use the created role
    create_iam_instance_profile = true
    iam_role_policies          = {
      "SSMManagedInstanceCore" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
    
    # Metadata options
    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 1
      instance_metadata_tags      = "enabled"
    }
    
    # Tags
    tags = {
      Name = "web-server"
      Role = "web"
      Tier = "frontend"
      Environment = "$ENVIRONMENT"
      ManagedBy = "github-actions"
      Project = "$PROJECT"
    }
  }
}

# Global settings
global_settings = {
  enable_monitoring = true
  enable_ebs_optimization = true
  enable_termination_protection = false
  enable_stop_protection = false
  create_iam_profiles = true
  iam_role_policies = {
    "SSMManagedInstanceCore" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  additional_tags = {
    ManagedBy = "github-actions"
    Repository = "your-repo-name"
    Workflow = "deploy-ec2"
    Environment = "$ENVIRONMENT"
    Project = "$PROJECT"
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

# System tags configuration
managed_by_tag = "terraform"
feature_tag = "adaptive-iam"
ec2_service_principal = "ec2.amazonaws.com"
assume_role_policy_version = "2012-10-17"
default_role_name = "default"

# User data configuration
enable_user_data_template = true
user_data_template_path = "templates/user_data.sh"
user_data = null
user_data_base64 = null
user_data_replace_on_change = false
EOF

# Create user data template
echo "📝 Creating user data template..."
cat > "$INPUT_DIR/templates/user_data.sh" << 'EOF'
#!/bin/bash

# User Data Template for EC2 Instance Initialization
# Variables: ${hostname}, ${role}, ${environment}

set -e

# Update system
echo "Updating system packages..."
yum update -y

# Install common packages
echo "Installing common packages..."
yum install -y \
    httpd \
    php \
    wget \
    curl \
    git \
    unzip \
    htop \
    tree \
    jq

# Configure hostname
echo "Configuring hostname..."
hostnamectl set-hostname ${hostname}

# Configure Apache (if role is web)
if [ "${role}" = "web" ]; then
    echo "Configuring Apache web server..."
    
    # Start and enable Apache
    systemctl start httpd
    systemctl enable httpd
    
    # Create a simple index page
    cat > /var/www/html/index.html << 'HTML_EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Welcome to ${hostname}</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 40px; }
        .container { max-width: 800px; margin: 0 auto; }
        .header { background: #f0f0f0; padding: 20px; border-radius: 5px; }
        .info { margin: 20px 0; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>Welcome to ${hostname}</h1>
            <p>This server is managed by Terraform and GitHub Actions</p>
        </div>
        <div class="info">
            <h2>Server Information</h2>
            <ul>
                <li><strong>Hostname:</strong> ${hostname}</li>
                <li><strong>Role:</strong> ${role}</li>
                <li><strong>Environment:</strong> ${environment}</li>
                <li><strong>Instance ID:</strong> $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</li>
                <li><strong>Availability Zone:</strong> $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</li>
                <li><strong>Launch Time:</strong> $(date)</li>
            </ul>
        </div>
        <div class="info">
            <h2>SSM Access</h2>
            <p>This instance is configured for AWS Systems Manager (SSM) access. You can connect using:</p>
            <ul>
                <li><strong>AWS CLI:</strong> aws ssm start-session --target $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</li>
                <li><strong>AWS Console:</strong> Go to EC2 → Instances → Select this instance → Connect → Session Manager</li>
            </ul>
        </div>
    </div>
</body>
</html>
HTML_EOF
fi

# Create a system information script
cat > /usr/local/bin/system-info << 'SCRIPT_EOF'
#!/bin/bash
echo "=== System Information ==="
echo "Hostname: $(hostname)"
echo "Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
echo "Instance Type: $(curl -s http://169.254.169.254/latest/meta-data/instance-type)"
echo "Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)"
echo "Private IP: $(curl -s http://169.254.169.254/latest/meta-data/local-ipv4)"
echo "Public IP: $(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)"
echo "Launch Time: $(date)"
echo ""
echo "=== SSM Connection Info ==="
echo "To connect via SSM:"
echo "aws ssm start-session --target $(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
echo ""
echo "=== Disk Usage ==="
df -h
echo ""
echo "=== Memory Usage ==="
free -h
SCRIPT_EOF

chmod +x /usr/local/bin/system-info

# Create a log file for this initialization
echo "User data initialization completed at $(date)" > /var/log/user-data-init.log

# Send completion notification
echo "EC2 instance initialization completed successfully!"
echo "Hostname: ${hostname}"
echo "Role: ${role}"
echo "Environment: ${environment}"
echo "SSM Access: aws ssm start-session --target $(curl -s http://169.254.169.254/latest/meta-data/instance-id)"
EOF

chmod +x "$INPUT_DIR/templates/user_data.sh"

# Create environment-specific configurations
echo "🌍 Creating environment-specific configurations..."

# Development environment
cat > "$INPUT_DIR/environments/dev/terraform.tfvars" << EOF
# Development Environment Configuration
aws_region = "$REGION"

# Project Configuration
environment  = "development"
project_name = "$PROJECT-dev"

# Security Group Configuration
create_security_group = true
security_group_name = "security-group"
security_group_use_name_prefix = false
security_group_description = "Security group for EC2 instances"
security_group_vpc_id = "vpc-3d80a556"

# IAM Configuration
iam_role_name = "iam-role"
iam_role_use_name_prefix = false
iam_role_description = "IAM role for EC2 instances with SSM access"

# Instance configurations for development
instances = {
  dev_web_server = {
    name                        = "dev-web-server"
    ami                         = "ami-0c02fb55956c7d316"
    instance_type              = "t3.micro"
    availability_zone          = "${REGION}a"
    subnet_id                  = "subnet-a65c14eb"
    associate_public_ip_address = true
    
    user_data_template_vars = {
      hostname = "dev-web-server"
      role     = "web"
      environment = "development"
    }
    
    root_block_device = {
      size       = 20
      type       = "gp3"
      encrypted  = true
      throughput = 125
      tags = {
        Name = "dev-web-server-root"
        Environment = "development"
      }
    }
    
    disable_api_stop       = false
    disable_api_termination = false
    ebs_optimized          = true
    monitoring             = true
    
    create_iam_instance_profile = true
    iam_role_policies          = {
      "SSMManagedInstanceCore" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
    
    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 1
      instance_metadata_tags      = "enabled"
    }
    
    tags = {
      Name = "dev-web-server"
      Role = "web"
      Tier = "frontend"
      Environment = "development"
      ManagedBy = "github-actions"
      Project = "$PROJECT"
    }
  }
}

# Global settings for development
global_settings = {
  enable_monitoring = true
  enable_ebs_optimization = true
  enable_termination_protection = false
  enable_stop_protection = false
  create_iam_profiles = true
  iam_role_policies = {
    "SSMManagedInstanceCore" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  additional_tags = {
    ManagedBy = "github-actions"
    Repository = "your-repo-name"
    Workflow = "deploy-ec2"
    Environment = "development"
    Project = "$PROJECT"
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

# System tags configuration
managed_by_tag = "terraform"
feature_tag = "adaptive-iam"
ec2_service_principal = "ec2.amazonaws.com"
assume_role_policy_version = "2012-10-17"
default_role_name = "default"

# User data configuration
enable_user_data_template = true
user_data_template_path = "../../templates/user_data.sh"
user_data = null
user_data_base64 = null
user_data_replace_on_change = false
EOF

# Production environment
cat > "$INPUT_DIR/environments/prod/terraform.tfvars" << EOF
# Production Environment Configuration
aws_region = "$REGION"

# Project Configuration
environment  = "production"
project_name = "$PROJECT-prod"

# Security Group Configuration
create_security_group = true
security_group_name = "security-group"
security_group_use_name_prefix = false
security_group_description = "Security group for EC2 instances"
security_group_vpc_id = "vpc-3d80a556"

# IAM Configuration
iam_role_name = "iam-role"
iam_role_use_name_prefix = false
iam_role_description = "IAM role for EC2 instances with SSM access"

# Instance configurations for production
instances = {
  prod_web_server = {
    name                        = "prod-web-server"
    ami                         = "ami-0c02fb55956c7d316"
    instance_type              = "t3.small"
    availability_zone          = "${REGION}a"
    subnet_id                  = "subnet-a65c14eb"
    associate_public_ip_address = true
    
    user_data_template_vars = {
      hostname = "prod-web-server"
      role     = "web"
      environment = "production"
    }
    
    root_block_device = {
      size       = 30
      type       = "gp3"
      encrypted  = true
      throughput = 125
      tags = {
        Name = "prod-web-server-root"
        Environment = "production"
      }
    }
    
    disable_api_stop       = true
    disable_api_termination = true
    ebs_optimized          = true
    monitoring             = true
    
    create_iam_instance_profile = true
    iam_role_policies          = {
      "SSMManagedInstanceCore" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
    }
    
    metadata_options = {
      http_endpoint               = "enabled"
      http_tokens                 = "required"
      http_put_response_hop_limit = 1
      instance_metadata_tags      = "enabled"
    }
    
    tags = {
      Name = "prod-web-server"
      Role = "web"
      Tier = "frontend"
      Environment = "production"
      ManagedBy = "github-actions"
      Project = "$PROJECT"
      Backup = "daily"
    }
  }
}

# Global settings for production
global_settings = {
  enable_monitoring = true
  enable_ebs_optimization = true
  enable_termination_protection = true
  enable_stop_protection = true
  create_iam_profiles = true
  iam_role_policies = {
    "SSMManagedInstanceCore" = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  }
  additional_tags = {
    ManagedBy = "github-actions"
    Repository = "your-repo-name"
    Workflow = "deploy-ec2"
    Environment = "production"
    Project = "$PROJECT"
    Backup = "daily"
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

# System tags configuration
managed_by_tag = "terraform"
feature_tag = "adaptive-iam"
ec2_service_principal = "ec2.amazonaws.com"
assume_role_policy_version = "2012-10-17"
default_role_name = "default"

# User data configuration
enable_user_data_template = true
user_data_template_path = "../../templates/user_data.sh"
user_data = null
user_data_base64 = null
user_data_replace_on_change = false
EOF

# Create README for the user input directory
cat > "$INPUT_DIR/README.md" << EOF
# User Input Directory: $INPUT_DIR

This directory contains your Terraform configuration files for deploying EC2 instances using the wrapper module.

## 🚀 Quick Start

1. **Configure your AWS credentials** in GitHub repository secrets:
   - \`AWS_ACCESS_KEY_ID\`
   - \`AWS_SECRET_ACCESS_KEY\`
   - \`AWS_REGION\`

2. **Update your configuration** by editing \`terraform.tfvars\`:
   - VPC ID is already set to vpc-3d80a556
   - Customize instance configurations as needed

3. **Run the GitHub Action**:
   - Go to Actions tab in your repository
   - Select "Deploy EC2 Instances" workflow
   - Click "Run workflow"
   - Set the user input directory to \`$INPUT_DIR\`
   - Choose action: \`plan\`, \`apply\`, or \`destroy\`

## 📁 Directory Structure

\`\`\`
$INPUT_DIR/
├── README.md                    # This file
├── main.tf                     # References the wrapper module
├── variables.tf                # Variable definitions
├── outputs.tf                  # Output definitions
├── terraform.tfvars            # Your main configuration file
├── environments/               # Environment-specific configurations
│   ├── dev/
│   │   └── terraform.tfvars    # Development configuration
│   └── prod/
│       └── terraform.tfvars    # Production configuration
└── templates/                  # User data templates
    └── user_data.sh
\`\`\`

## 🔧 Configuration

### Required Changes

Before running the action, verify these values in your \`terraform.tfvars\`:

- \`security_group_vpc_id\`: Set to vpc-3d80a556
- \`subnet_id\`: Set to subnet-a65c14eb

### Features

- **SSM Access**: All instances are configured for AWS Systems Manager access
- **No Key Pairs**: Instances use SSM for secure access instead of SSH keys
- **Security Groups**: Automatically created with name "security-group" (no prefixes)
- **IAM Roles**: Automatically created with name "iam-role" (no prefixes)

### Environment-Specific Deployments

- **Development**: Use \`$INPUT_DIR/environments/dev/\`
- **Production**: Use \`$INPUT_DIR/environments/prod/\`

## 🔐 SSM Access

All instances are configured for AWS Systems Manager access:

- **AWS CLI**: \`aws ssm start-session --target <instance-id>\`
- **AWS Console**: EC2 → Instances → Select instance → Connect → Session Manager

## 📚 Additional Resources

- [GitHub Action Setup Guide](../GITHUB_ACTION_SETUP.md)
- [Wrapper Module Documentation](../wrapper/README.md)
- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS SSM Documentation](https://docs.aws.amazon.com/systems-manager/)
EOF

echo "✅ Setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. VPC ID is already set to vpc-3d80a556"
echo "2. Configure GitHub secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION)"
echo "3. Run the GitHub Action with user input directory: $INPUT_DIR"
echo ""
echo "📁 Created directory structure:"
echo "  $INPUT_DIR/"
echo "  ├── main.tf (references wrapper module)"
echo "  ├── variables.tf"
echo "  ├── outputs.tf"
echo "  ├── terraform.tfvars"
echo "  ├── environments/dev/terraform.tfvars"
echo "  ├── environments/prod/terraform.tfvars"
echo "  └── templates/user_data.sh"
echo ""
echo "🔧 Key Features:"
echo "  ✅ Security group name: security-group (no prefixes/suffixes)"
echo "  ✅ IAM role name: iam-role (no prefixes/suffixes)"
echo "  ✅ VPC ID set to vpc-3d80a556"
echo "  ✅ Subnet ID set to subnet-a65c14eb"
echo "  ✅ No key pairs required - SSM access only"
echo "  ✅ Proper Terraform module structure"
echo ""
echo "🔧 To customize further, edit the configuration files and refer to:"
echo "  - GITHUB_ACTION_SETUP.md for detailed instructions"
echo "  - wrapper/README.md for module documentation"