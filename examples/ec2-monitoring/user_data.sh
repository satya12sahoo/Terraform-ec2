#!/bin/bash
# User Data Script for EC2 Instance with CloudWatch Agent
# This script installs and configures the CloudWatch agent

set -e

# Update system packages
yum update -y

# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Install AWS CLI v2 (if not already installed)
if ! command -v aws &> /dev/null; then
    curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
    unzip awscliv2.zip
    ./aws/install
    rm -rf aws awscliv2.zip
fi

# Create CloudWatch agent configuration directory
mkdir -p /opt/aws/amazon-cloudwatch-agent/etc/

# Download configuration from SSM Parameter Store
aws ssm get-parameter \
    --name "${ssm_parameter_name}" \
    --region ${aws_region} \
    --query "Parameter.Value" \
    --output text > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Start CloudWatch agent with the configuration
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
    -a fetch-config \
    -m ec2 \
    -s \
    -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Enable and start CloudWatch agent service
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent

# Verify the agent is running
systemctl status amazon-cloudwatch-agent

# Create a simple test log entry
echo "$(date): CloudWatch agent installation completed successfully" >> /var/log/cloudwatch-agent-setup.log

# Optional: Install additional monitoring tools
yum install -y htop iotop

echo "CloudWatch agent setup completed successfully!"