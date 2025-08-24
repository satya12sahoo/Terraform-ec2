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
    php-mysqlnd \
    php-json \
    php-xml \
    php-mbstring \
    php-gd \
    php-curl \
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
    cat > /var/www/html/index.html << 'EOF'
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
            <h2>System Status</h2>
            <pre>$(systemctl status httpd --no-pager -l)</pre>
        </div>
    </div>
</body>
</html>
EOF

    # Configure PHP (if installed)
    if command -v php &> /dev/null; then
        echo "Configuring PHP..."
        cat > /var/www/html/info.php << 'EOF'
<?php
phpinfo();
?>
EOF
    fi
fi

# Configure application server (if role is application)
if [ "${role}" = "application" ]; then
    echo "Configuring application server..."
    
    # Install Node.js (example for application server)
    curl -fsSL https://rpm.nodesource.com/setup_18.x | bash -
    yum install -y nodejs
    
    # Install PM2 for process management
    npm install -g pm2
    
    # Create a simple Node.js application
    mkdir -p /opt/app
    cat > /opt/app/app.js << 'EOF'
const express = require('express');
const app = express();
const port = 3000;

app.get('/', (req, res) => {
    res.json({
        message: 'Hello from Application Server!',
        hostname: '${hostname}',
        role: '${role}',
        environment: '${environment}',
        timestamp: new Date().toISOString(),
        instanceId: process.env.INSTANCE_ID || 'unknown'
    });
});

app.get('/health', (req, res) => {
    res.json({ status: 'healthy', timestamp: new Date().toISOString() });
});

app.listen(port, '0.0.0.0', () => {
    console.log(`Application server running on port ${port}`);
});
EOF

    cat > /opt/app/package.json << 'EOF'
{
  "name": "app-server",
  "version": "1.0.0",
  "description": "Sample application server",
  "main": "app.js",
  "scripts": {
    "start": "node app.js"
  },
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

    # Install dependencies and start application
    cd /opt/app
    npm install
    pm2 start app.js
    pm2 startup
    pm2 save
fi

# Configure CloudWatch Agent (if monitoring is enabled)
if command -v amazon-cloudwatch-agent &> /dev/null; then
    echo "Configuring CloudWatch Agent..."
    /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl \
        -a fetch-config \
        -m ec2 \
        -s \
        -c ssm:${cloudwatch_config_parameter}
fi

# Create a system information script
cat > /usr/local/bin/system-info << 'EOF'
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
echo ""
echo "=== Running Services ==="
systemctl list-units --type=service --state=running
EOF

chmod +x /usr/local/bin/system-info

# Create a log file for this initialization
echo "User data initialization completed at $(date)" > /var/log/user-data-init.log

# Send completion notification
echo "EC2 instance initialization completed successfully!"
echo "Hostname: ${hostname}"
echo "Role: ${role}"
echo "Environment: ${environment}"