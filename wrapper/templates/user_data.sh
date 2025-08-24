#!/bin/bash

# Set hostname
hostnamectl set-hostname ${hostname}

# Update system
yum update -y

# Install common packages
yum install -y \
    wget \
    curl \
    git \
    unzip \
    jq \
    htop \
    tree \
    vim \
    net-tools \
    nfs-utils

# Configure system based on role
case "${role}" in
    "web")
        # Install web server packages
        yum install -y httpd php php-mysqlnd
        
        # Start and enable Apache
        systemctl start httpd
        systemctl enable httpd
        
        # Create web content directory
        mkdir -p /var/www/html
        echo "<h1>Welcome to ${hostname}</h1><p>Role: ${role}</p>" > /var/www/html/index.html
        
        # Configure firewall
        firewall-cmd --permanent --add-service=http
        firewall-cmd --permanent --add-service=https
        firewall-cmd --reload
        ;;
        
    "application")
        # Install application server packages
        yum install -y java-11-amazon-corretto-headless tomcat
        
        # Start and enable Tomcat
        systemctl start tomcat
        systemctl enable tomcat
        
        # Create application directories
        mkdir -p /opt/app/{logs,config,data}
        
        # Configure firewall
        firewall-cmd --permanent --add-port=8080/tcp
        firewall-cmd --reload
        ;;
        
    "database")
        # Install database packages
        yum install -y mysql mysql-server
        
        # Start and enable MySQL
        systemctl start mysqld
        systemctl enable mysqld
        
        # Secure MySQL installation
        mysql_secure_installation --use-default
        
        # Create database directories
        mkdir -p /var/lib/mysql/{data,backup}
        
        # Configure firewall
        firewall-cmd --permanent --add-port=3306/tcp
        firewall-cmd --reload
        ;;
        
    *)
        echo "Unknown role: ${role}"
        ;;
esac

# Configure logging
mkdir -p /var/log/app
echo "$(date): Instance ${hostname} with role ${role} initialized" >> /var/log/app/init.log

# Set up log rotation
cat > /etc/logrotate.d/app << EOF
/var/log/app/*.log {
    daily
    missingok
    rotate 7
    compress
    notifempty
    create 644 root root
}
EOF

# Create monitoring script
cat > /opt/monitor.sh << 'EOF'
#!/bin/bash
echo "$(date): System monitoring check" >> /var/log/app/monitor.log
df -h >> /var/log/app/monitor.log
free -m >> /var/log/app/monitor.log
echo "---" >> /var/log/app/monitor.log
EOF

chmod +x /opt/monitor.sh

# Add monitoring to crontab
echo "*/5 * * * * /opt/monitor.sh" | crontab -

# Final system message
echo "Instance ${hostname} (${role}) initialization completed at $(date)" >> /var/log/app/init.log