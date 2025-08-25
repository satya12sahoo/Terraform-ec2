#!/bin/bash

# User Data Template for EC2 Instance Configuration
# This script is used by the wrapper module to configure instances on startup

set -e

# Log all output to a file for debugging
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1

echo "Starting user data script execution..."

# Update system packages
echo "Updating system packages..."
yum update -y

# Install common packages
echo "Installing common packages..."
yum install -y \
    aws-cli \
    jq \
    htop \
    wget \
    curl \
    unzip \
    git

# Configure hostname if provided
if [ -n "${hostname}" ]; then
    echo "Setting hostname to ${hostname}..."
    hostnamectl set-hostname "${hostname}"
    echo "${hostname}" > /etc/hostname
fi

# Create application user
echo "Creating application user..."
useradd -m -s /bin/bash appuser || true
usermod -aG wheel appuser

# Create application directory
mkdir -p /opt/app
chown appuser:appuser /opt/app

# Configure CloudWatch Agent if monitoring is enabled
if [ "${monitoring}" = "true" ]; then
    echo "Configuring CloudWatch Agent..."
    yum install -y amazon-cloudwatch-agent
    
    # Create CloudWatch Agent configuration
    cat > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json << 'EOF'
{
    "agent": {
        "metrics_collection_interval": 60,
        "run_as_user": "cwagent"
    },
    "logs": {
        "logs_collected": {
            "files": {
                "collect_list": [
                    {
                        "file_path": "/var/log/messages",
                        "log_group_name": "/aws/ec2/{instance_id}/messages",
                        "log_stream_name": "{instance_id}"
                    },
                    {
                        "file_path": "/var/log/user-data.log",
                        "log_group_name": "/aws/ec2/{instance_id}/user-data",
                        "log_stream_name": "{instance_id}"
                    }
                ]
            }
        }
    },
    "metrics": {
        "metrics_collected": {
            "disk": {
                "measurement": [
                    "used_percent"
                ],
                "metrics_collection_interval": 60,
                "resources": [
                    "*"
                ]
            },
            "mem": {
                "measurement": [
                    "mem_used_percent"
                ],
                "metrics_collection_interval": 60
            }
        }
    }
}
EOF

    # Start CloudWatch Agent
    systemctl enable amazon-cloudwatch-agent
    systemctl start amazon-cloudwatch-agent
fi

# Role-specific configurations
case "${role}" in
    "web")
        echo "Configuring web server..."
        
        # Install web server (Apache)
        yum install -y httpd
        systemctl enable httpd
        systemctl start httpd
        
        # Create simple index page
        cat > /var/www/html/index.html << EOF
<!DOCTYPE html>
<html>
<head>
    <title>EC2 Instance - ${hostname}</title>
</head>
<body>
    <h1>Welcome to ${hostname}</h1>
    <p>This is a web server instance deployed via Terraform.</p>
    <p>Environment: ${environment}</p>
    <p>Role: ${role}</p>
    <p>Instance ID: $(curl -s http://169.254.169.254/latest/meta-data/instance-id)</p>
    <p>Availability Zone: $(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)</p>
</body>
</html>
EOF
        
        # Configure firewall
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        firewall-cmd --reload
        ;;
        
    "database")
        echo "Configuring database server..."
        
        # Install database server (MySQL)
        yum install -y mysql-server
        systemctl enable mysqld
        systemctl start mysqld
        
        # Secure MySQL installation
        mysql_secure_installation << EOF

y
1
2
y
y
y
y
EOF
        
        # Create application database
        mysql -u root -p'root' << EOF
CREATE DATABASE IF NOT EXISTS appdb;
CREATE USER 'appuser'@'localhost' IDENTIFIED BY 'apppassword';
GRANT ALL PRIVILEGES ON appdb.* TO 'appuser'@'localhost';
FLUSH PRIVILEGES;
EOF
        
        # Configure firewall
        firewall-cmd --permanent --add-service=mysql
        firewall-cmd --reload
        ;;
        
    "application")
        echo "Configuring application server..."
        
        # Install Java (for Spring Boot applications)
        yum install -y java-11-amazon-corretto
        
        # Create application directory
        mkdir -p /opt/app
        chown appuser:appuser /opt/app
        
        # Create systemd service file
        cat > /etc/systemd/system/app.service << EOF
[Unit]
Description=Application Service
After=network.target

[Service]
Type=simple
User=appuser
WorkingDirectory=/opt/app
ExecStart=/usr/bin/java -jar /opt/app/app.jar
Restart=always
RestartSec=10

[Install]
WantedBy=multi-user.target
EOF
        
        systemctl daemon-reload
        systemctl enable app
        ;;
        
    *)
        echo "No specific role configuration for: ${role}"
        ;;
esac

# Environment-specific configurations
case "${environment}" in
    "development")
        echo "Configuring development environment..."
        # Add development-specific configurations
        ;;
        
    "staging")
        echo "Configuring staging environment..."
        # Add staging-specific configurations
        ;;
        
    "production")
        echo "Configuring production environment..."
        # Add production-specific configurations
        
        # Enable additional security measures
        yum install -y fail2ban
        systemctl enable fail2ban
        systemctl start fail2ban
        ;;
esac

# Configure log rotation
cat > /etc/logrotate.d/user-data << EOF
/var/log/user-data.log {
    daily
    missingok
    rotate 7
    compress
    notifempty
    create 644 root root
}
EOF

# Set up monitoring and alerting
if [ "${monitoring}" = "true" ]; then
    # Create custom CloudWatch metric for instance health
    cat > /opt/health-check.sh << 'EOF'
#!/bin/bash
# Health check script for CloudWatch

INSTANCE_ID=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)
REGION=$(curl -s http://169.254.169.254/latest/meta-data/placement/region)

# Check if instance is healthy (customize based on your application)
HEALTH_STATUS=1

# Send custom metric to CloudWatch
aws cloudwatch put-metric-data \
    --namespace "EC2/InstanceHealth" \
    --metric-data MetricName=HealthStatus,Value=$HEALTH_STATUS,Unit=Count,Dimensions=InstanceId=$INSTANCE_ID \
    --region $REGION
EOF

    chmod +x /opt/health-check.sh
    
    # Add to crontab to run every 5 minutes
    (crontab -l 2>/dev/null; echo "*/5 * * * * /opt/health-check.sh") | crontab -
fi

# Final system configuration
echo "Performing final system configuration..."

# Set timezone
timedatectl set-timezone UTC

# Configure SSH (optional security hardening)
if [ "${environment}" = "production" ]; then
    # Disable root login
    sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config
    
    # Disable password authentication
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
    
    # Restart SSH service
    systemctl restart sshd
fi

# Create completion marker
echo "User data script completed successfully at $(date)" > /var/log/user-data-complete

echo "User data script execution completed!"