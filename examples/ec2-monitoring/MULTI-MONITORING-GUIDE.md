# Multi-Monitoring Configuration Guide

This guide explains how to use the EC2 monitoring module with different monitoring profiles and custom dashboard configurations for various server types.

## 🎯 **Monitoring Profiles Overview**

The module supports predefined monitoring profiles optimized for different server types:

| Profile | Use Case | CPU Threshold | Memory Threshold | Focus Areas |
|---------|----------|---------------|------------------|-------------|
| **default** | General purpose | 80% | 80% | Basic system metrics |
| **web_server** | Web applications | 70% | 75% | Response time, error rates |
| **database_server** | Database systems | 60% | 70% | I/O performance, connections |
| **application_server** | Application servers | 80% | 80% | Application errors, performance |

## 🚀 **Quick Start Examples**

### **1. Web Server with Enhanced Monitoring**

```hcl
module "web_server_monitoring" {
  source = "../../modules/ec2-monitoring"
  
  ec2_instance_name = "web-server"
  
  # Use web server profile
  monitoring_profiles = {
    profile = "web_server"
    web_server = {
      cpu_threshold = 70
      memory_threshold = 75
      disk_threshold = 80
      response_time_threshold = 1000
    }
  }
  
  # Custom alarms for web-specific metrics
  custom_alarms = [
    {
      name = "high-response-time"
      description = "HTTP response time is too high"
      metric_name = "ResponseTime"
      namespace = "WebServer"
      comparison_operator = "GreaterThanThreshold"
      threshold = 1000
      period = 300
      evaluation_periods = 2
      statistic = "Average"
      dimensions = {
        InstanceId = "web-server"
        Service = "web"
      }
    }
  ]
}
```

### **2. Database Server with I/O Focus**

```hcl
module "database_server_monitoring" {
  source = "../../modules/ec2-monitoring"
  
  ec2_instance_name = "database-server"
  
  # Use database server profile
  monitoring_profiles = {
    profile = "database_server"
    database_server = {
      cpu_threshold = 60
      memory_threshold = 70
      disk_threshold = 85
      connection_threshold = 100
    }
  }
  
  # Custom alarms for database metrics
  custom_alarms = [
    {
      name = "high-connection-count"
      description = "Database connection count is too high"
      metric_name = "DatabaseConnections"
      namespace = "Database"
      comparison_operator = "GreaterThanThreshold"
      threshold = 100
      period = 300
      evaluation_periods = 2
      statistic = "Average"
      dimensions = {
        InstanceId = "database-server"
        Service = "database"
      }
    }
  ]
}
```

### **3. Development Server with Minimal Monitoring**

```hcl
module "dev_server_monitoring" {
  source = "../../modules/ec2-monitoring"
  
  ec2_instance_name = "dev-server"
  
  # Minimal monitoring - only essential resources
  create_dashboard = false
  create_log_group = false
  create_cpu_alarm = false
  create_memory_alarm = false
  
  tags = {
    Environment = "development"
    Monitoring  = "minimal"
  }
}
```

## 🎨 **Custom Dashboard Configuration**

### **Dashboard Widget Types**

The module supports all CloudWatch dashboard widget types:

```hcl
dashboard_config = {
  widgets = [
    {
      type   = "metric"           # metric, text, log, alarm
      x      = 0                  # X position (0-23)
      y      = 0                  # Y position (0-23)
      width  = 12                 # Width (1-24)
      height = 6                  # Height (1-24)
      properties = {
        metrics = [               # Array of metric arrays
          ["AWS/EC2", "CPUUtilization", "InstanceId", "my-server"],
          [".", "NetworkIn", ".", "."],
          [".", "NetworkOut", ".", "."]
        ]
        period = 300              # Time period in seconds
        stat   = "Average"        # Statistic: Average, Sum, Min, Max
        region = "us-west-2"      # AWS region
        title  = "My Custom Title"
        view   = "timeSeries"     # timeSeries, bar, pie
        stacked = false           # Stack metrics
        yAxis = {                 # Y-axis configuration
          left = {
            min = 0
            max = 100
            showUnits = false
          }
        }
      }
    }
  ]
}
```

### **Common Dashboard Patterns**

#### **System Overview Dashboard**
```hcl
dashboard_config = {
  widgets = [
    # Top row: System metrics
    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 12
      height = 6
      properties = {
        metrics = [
          ["AWS/EC2", "CPUUtilization", "InstanceId", "my-server"],
          [".", "NetworkIn", ".", "."],
          [".", "NetworkOut", ".", "."]
        ]
        period = 300
        stat   = "Average"
        title  = "System Performance"
      }
    },
    # Top row: Resource usage
    {
      type   = "metric"
      x      = 12
      y      = 0
      width  = 12
      height = 6
      properties = {
        metrics = [
          ["CWAgent", "mem_used_percent", "InstanceId", "my-server"],
          [".", "disk_used_percent", ".", "."]
        ]
        period = 300
        stat   = "Average"
        title  = "Resource Usage"
      }
    },
    # Bottom row: Application metrics
    {
      type   = "metric"
      x      = 0
      y      = 6
      width  = 24
      height = 6
      properties = {
        metrics = [
          ["Application", "ResponseTime", "InstanceId", "my-server"],
          [".", "RequestCount", ".", "."],
          [".", "ErrorRate", ".", "."]
        ]
        period = 300
        stat   = "Average"
        title  = "Application Performance"
      }
    }
  ]
}
```

#### **Multi-Instance Dashboard**
```hcl
dashboard_config = {
  widgets = [
    {
      type   = "metric"
      x      = 0
      y      = 0
      width  = 24
      height = 6
      properties = {
        metrics = [
          ["AWS/EC2", "CPUUtilization", "InstanceId", "web-server-1"],
          [".", ".", ".", "web-server-2"],
          [".", ".", ".", "web-server-3"]
        ]
        period = 300
        stat   = "Average"
        title  = "Web Server Cluster CPU Usage"
        view   = "timeSeries"
      }
    }
  ]
}
```

## 🔧 **Custom Alarms Configuration**

### **Alarm Types**

```hcl
custom_alarms = [
  # High threshold alarm
  {
    name = "high-cpu"
    description = "CPU usage is too high"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    comparison_operator = "GreaterThanThreshold"
    threshold = 80
    period = 300
    evaluation_periods = 2
    statistic = "Average"
    dimensions = {
      InstanceId = "my-server"
    }
  },
  
  # Low threshold alarm
  {
    name = "low-requests"
    description = "Request count is too low (possible outage)"
    metric_name = "RequestCount"
    namespace = "Application"
    comparison_operator = "LessThanThreshold"
    threshold = 10
    period = 300
    evaluation_periods = 3
    statistic = "Sum"
    dimensions = {
      InstanceId = "my-server"
    }
  },
  
  # Anomaly detection
  {
    name = "anomalous-behavior"
    description = "Unusual system behavior detected"
    metric_name = "CPUUtilization"
    namespace = "AWS/EC2"
    comparison_operator = "GreaterThanUpperThreshold"
    threshold = 0
    period = 300
    evaluation_periods = 2
    extended_statistic = "p95"
    dimensions = {
      InstanceId = "my-server"
    }
  }
]
```

### **Alarm Actions**

```hcl
custom_alarms = [
  {
    name = "critical-alarm"
    # ... other alarm configuration ...
    
    # SNS notification
    alarm_actions = ["arn:aws:sns:us-west-2:123456789012:alerts-topic"]
    
    # Auto-scaling actions
    alarm_actions = ["arn:aws:autoscaling:us-west-2:123456789012:scalingPolicy:policy-id"]
    
    # Multiple actions
    alarm_actions = [
      "arn:aws:sns:us-west-2:123456789012:alerts-topic",
      "arn:aws:autoscaling:us-west-2:123456789012:scalingPolicy:policy-id"
    ]
  }
]
```

## 📊 **Monitoring Profile Details**

### **Web Server Profile**
- **CPU Threshold**: 70% (lower for web servers)
- **Memory Threshold**: 75%
- **Focus**: Response time, error rates, request counts
- **Custom Metrics**: HTTP performance, user experience
- **Logs**: Access logs, error logs, application logs

### **Database Server Profile**
- **CPU Threshold**: 60% (lower for database servers)
- **Memory Threshold**: 70%
- **Focus**: I/O performance, connection counts, query latency
- **Custom Metrics**: Database performance, cache hit ratios
- **Logs**: Database logs, slow query logs, error logs

### **Application Server Profile**
- **CPU Threshold**: 80% (standard for application servers)
- **Memory Threshold**: 80%
- **Focus**: Application errors, response times, throughput
- **Custom Metrics**: Business metrics, application health
- **Logs**: Application logs, error logs, performance logs

## 🎛️ **Advanced Configuration Options**

### **Conditional Monitoring**

```hcl
# Enable enhanced monitoring only in production
monitoring_profiles = {
  profile = var.environment == "production" ? "web_server" : "default"
}

# Customize based on instance type
custom_alarms = var.instance_type == "t3.large" ? [
  {
    name = "high-memory"
    # ... large instance specific alarm
  }
] : []

# Environment-specific dashboards
dashboard_config = var.environment == "production" ? var.production_dashboard : var.development_dashboard
```

### **Dynamic Resource Naming**

```hcl
# Use environment in resource names
monitoring_profiles = {
  profile = "web_server"
  web_server = {
    cpu_threshold = var.environment == "production" ? 70 : 90
    memory_threshold = var.environment == "production" ? 75 : 90
  }
}

# Environment-specific tags
tags = merge(var.base_tags, {
  Environment = var.environment
  Monitoring  = var.environment == "production" ? "enhanced" : "basic"
})
```

## 📈 **Best Practices**

### **1. Profile Selection**
- Use appropriate profiles for server types
- Customize thresholds based on workload
- Consider environment requirements

### **2. Dashboard Design**
- Keep dashboards focused and readable
- Use consistent layouts across similar servers
- Include both system and application metrics

### **3. Alarm Configuration**
- Set appropriate thresholds for each environment
- Use different evaluation periods for different metrics
- Include meaningful descriptions and actions

### **4. Resource Management**
- Disable unnecessary resources in development
- Use consistent naming conventions
- Tag resources appropriately

## 🔍 **Troubleshooting**

### **Common Issues**

1. **Dashboard Not Displaying**
   - Check widget coordinates (x, y, width, height)
   - Verify metric namespaces and dimensions
   - Ensure metrics are being published

2. **Alarms Not Triggering**
   - Verify metric collection is working
   - Check alarm thresholds and periods
   - Ensure IAM permissions for alarm actions

3. **Custom Metrics Missing**
   - Verify CloudWatch agent configuration
   - Check agent logs for errors
   - Ensure custom metrics are being published

### **Debugging Commands**

```bash
# Check CloudWatch agent status
systemctl status amazon-cloudwatch-agent

# View agent logs
tail -f /opt/aws/amazon-cloudwatch-agent/logs/amazon-cloudwatch-agent.log

# Test metric publishing
aws cloudwatch put-metric-data --namespace TestNamespace --metric-data MetricName=TestMetric,Value=1

# List CloudWatch metrics
aws cloudwatch list-metrics --namespace AWS/EC2
```

## 📚 **Next Steps**

- Review the [profile examples](../profiles/) for specific use cases
- Customize dashboards for your application metrics
- Set up SNS topics for alarm notifications
- Implement auto-scaling based on CloudWatch alarms
- Create custom CloudWatch Insights queries for log analysis