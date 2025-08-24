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

# Copy wrapper module files
echo "📋 Copying wrapper module files..."
cp -r wrapper/* "$INPUT_DIR/"

# Create main terraform.tfvars
echo "⚙️ Creating main terraform.tfvars..."
cat > "$INPUT_DIR/terraform.tfvars" << EOF
# AWS Configuration
aws_region = "$REGION"

# Project Configuration
environment  = "$ENVIRONMENT"
project_name = "$PROJECT"

# Instance configurations
instances = {
  web_server = {
    name                        = "web-server"
    ami                         = "ami-0c02fb55956c7d316"  # Amazon Linux 2023 AMI
    instance_type              = "t3.micro"
    availability_zone          = "${REGION}a"
    subnet_id                  = "subnet-1234567890abcdef0"  # Replace with your subnet ID
    vpc_security_group_ids     = ["sg-1234567890abcdef0"]    # Replace with your security group ID
    associate_public_ip_address = true
    key_name                   = "your-key-pair"             # Replace with your key pair name
    
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
    
    # IAM configuration
    create_iam_instance_profile = false
    iam_role_policies          = {}
    
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
  create_iam_profiles = false
  iam_role_policies = {}
  additional_tags = {
    ManagedBy = "github-actions"
    Repository = "your-repo-name"
    Workflow = "deploy-ec2"
    Environment = "$ENVIRONMENT"
    Project = "$PROJECT"
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

# Instance configurations for development
instances = {
  dev_web_server = {
    name                        = "dev-web-server"
    ami                         = "ami-0c02fb55956c7d316"
    instance_type              = "t3.micro"
    availability_zone          = "${REGION}a"
    subnet_id                  = "subnet-1234567890abcdef0"
    vpc_security_group_ids     = ["sg-1234567890abcdef0"]
    associate_public_ip_address = true
    key_name                   = "dev-key-pair"
    
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
    
    create_iam_instance_profile = false
    iam_role_policies          = {}
    
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
  create_iam_profiles = false
  iam_role_policies = {}
  additional_tags = {
    ManagedBy = "github-actions"
    Repository = "your-repo-name"
    Workflow = "deploy-ec2"
    Environment = "development"
    Project = "$PROJECT"
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

# Instance configurations for production
instances = {
  prod_web_server = {
    name                        = "prod-web-server"
    ami                         = "ami-0c02fb55956c7d316"
    instance_type              = "t3.small"
    availability_zone          = "${REGION}a"
    subnet_id                  = "subnet-1234567890abcdef0"
    vpc_security_group_ids     = ["sg-1234567890abcdef0"]
    associate_public_ip_address = true
    key_name                   = "prod-key-pair"
    
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
    
    create_iam_instance_profile = false
    iam_role_policies          = {}
    
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
  create_iam_profiles = false
  iam_role_policies = {}
  additional_tags = {
    ManagedBy = "github-actions"
    Repository = "your-repo-name"
    Workflow = "deploy-ec2"
    Environment = "production"
    Project = "$PROJECT"
    Backup = "daily"
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
   - Replace placeholder subnet IDs, security group IDs, and key pair names
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

Before running the action, update these values in your \`terraform.tfvars\`:

- \`subnet_id\`: Your actual subnet ID
- \`vpc_security_group_ids\`: Your actual security group IDs
- \`key_name\`: Your actual EC2 key pair name

### Environment-Specific Deployments

- **Development**: Use \`$INPUT_DIR/environments/dev/\`
- **Production**: Use \`$INPUT_DIR/environments/prod/\`

## 📚 Additional Resources

- [GitHub Action Setup Guide](../GITHUB_ACTION_SETUP.md)
- [Wrapper Module Documentation](../wrapper/README.md)
- [Terraform Documentation](https://www.terraform.io/docs)
EOF

echo "✅ Setup completed successfully!"
echo ""
echo "📋 Next steps:"
echo "1. Update the AWS resource IDs in $INPUT_DIR/terraform.tfvars"
echo "2. Configure GitHub secrets (AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY, AWS_REGION)"
echo "3. Run the GitHub Action with user input directory: $INPUT_DIR"
echo ""
echo "📁 Created directory structure:"
echo "  $INPUT_DIR/"
echo "  ├── terraform.tfvars"
echo "  ├── environments/dev/terraform.tfvars"
echo "  ├── environments/prod/terraform.tfvars"
echo "  └── templates/user_data.sh"
echo ""
echo "🔧 To customize further, edit the configuration files and refer to:"
echo "  - GITHUB_ACTION_SETUP.md for detailed instructions"
echo "  - wrapper/README.md for module documentation"