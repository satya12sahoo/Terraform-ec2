# EC2 Monitoring Module Usage Guide

This guide explains how to use the EC2 monitoring module with its intelligent default configuration system.

## 🚀 **Zero-Configuration Setup**

The module is designed to work out-of-the-box with minimal input:

```hcl
module "ec2_monitoring" {
  source = "../../modules/ec2-monitoring"
  
  ec2_instance_name = "my-server"
}
```

That's it! The module will automatically:
- Create all necessary IAM resources with sensible names
- Set up CloudWatch monitoring and alarms
- Configure log collection and dashboards
- Use best practices for security and monitoring

## 📝 **Configuration Files**

### 1. **terraform.tfvars.minimal** (Recommended for beginners)
```hcl
# Only required variable
vpc_id = "vpc-12345678"

# Optional: Customize instance details
instance_name = "my-server"
environment   = "production"
```

### 2. **terraform.tfvars.example** (For advanced users)
Contains all available options with examples and explanations.

## 🔧 **Customization Options**

### **Resource Naming**
By default, resources are named using the pattern: `{instance_name}-{resource_type}`

```hcl
# These will be auto-generated:
# - my-server-CloudWatchAgentRole
# - my-server-CloudWatchAgentPolicy
# - my-server-Monitoring-Dashboard

# Override specific names if needed:
iam_role_name = "CustomRoleName"
dashboard_name = "CustomDashboard"
```

### **Monitoring Configuration**
```hcl
# Customize alarm thresholds
cpu_alarm_threshold    = 90
memory_alarm_threshold = 85

# Customize log retention
log_retention_days = 90

# Custom CloudWatch agent configuration
cloudwatch_agent_config = jsonencode({
  "agent": {
    "metrics_collection_interval": 30
  }
  # ... rest of your custom config
})
```

### **Resource Creation Control**
```hcl
# Disable specific resources if not needed
create_dashboard = false
create_cpu_alarm = false
create_log_group = false
```

## 📊 **What Gets Created**

### **Always Created (if enabled)**
- ✅ IAM Role with CloudWatch permissions
- ✅ IAM Policy for agent operations
- ✅ IAM Instance Profile for EC2 attachment
- ✅ SSM Parameter with agent configuration
- ✅ CloudWatch Dashboard with key metrics
- ✅ CloudWatch Log Groups for logs
- ✅ CPU and Memory utilization alarms

### **Default Configuration**
- **Metrics Collection**: Every 60 seconds
- **Log Collection**: System logs, security logs
- **Alarm Thresholds**: 80% for CPU and memory
- **Log Retention**: 30 days
- **Dashboard**: Real-time metrics display

## 🎯 **Common Use Cases**

### **1. Basic Monitoring**
```hcl
module "ec2_monitoring" {
  source = "../../modules/ec2-monitoring"
  
  ec2_instance_name = "web-server"
  tags = {
    Environment = "production"
    Project     = "website"
  }
}
```

### **2. High-Performance Monitoring**
```hcl
module "ec2_monitoring" {
  source = "../../modules/ec2-monitoring"
  
  ec2_instance_name = "db-server"
  
  # Aggressive monitoring
  cpu_alarm_threshold    = 70
  memory_alarm_threshold = 75
  
  # Custom agent config for database monitoring
  cloudwatch_agent_config = jsonencode({
    "agent": {
      "metrics_collection_interval": 30
    },
    "metrics": {
      "metrics_collected": {
        "disk": {
          "measurement": ["used_percent", "io_time"],
          "metrics_collection_interval": 30
        }
      }
    }
  })
}
```

### **3. Minimal Monitoring**
```hcl
module "ec2_monitoring" {
  source = "../../modules/ec2-monitoring"
  
  ec2_instance_name = "test-server"
  
  # Only create essential resources
  create_dashboard = false
  create_log_group = false
  create_cpu_alarm = false
  create_memory_alarm = false
}
```

## 🔍 **Troubleshooting**

### **Module Won't Apply**
- Check that `ec2_instance_name` is provided
- Ensure AWS credentials are configured
- Verify VPC ID exists in your account

### **Resources Not Created**
- Check the `create_*` flags in your configuration
- Verify IAM permissions for resource creation
- Check Terraform logs for specific errors

### **CloudWatch Agent Issues**
- Verify IAM role is attached to EC2 instance
- Check agent logs: `/opt/aws/amazon-cloudwatch-agent/logs/`
- Ensure SSM parameter exists and is accessible

## 💡 **Best Practices**

1. **Use Descriptive Instance Names**: They become part of resource names
2. **Tag Everything**: Helps with cost tracking and resource management
3. **Start Simple**: Use defaults first, customize as needed
4. **Monitor Costs**: CloudWatch has usage-based pricing
5. **Test Alarms**: Verify notifications work in your environment

## 📚 **Next Steps**

- Review the [main README](../../modules/ec2-monitoring/README.md) for detailed documentation
- Check the [examples directory](../) for more use cases
- Customize the CloudWatch agent configuration for your specific needs
- Set up SNS topics for alarm notifications
- Configure additional log sources and custom metrics