# Multi-Monitoring with for_each Example

This example demonstrates how to use the EC2 monitoring module with a `for_each` loop to create multiple monitoring configurations efficiently.

## 🎯 **What This Example Creates**

Using a single module call with `for_each`, it creates monitoring for:

- **web-server**: Enhanced monitoring with custom dashboard and alarms
- **database-server**: Database-focused monitoring with I/O metrics
- **app-server**: Standard monitoring with application-specific alarms
- **dev-server**: Minimal monitoring (development environment)

## 🚀 **Key Benefits of for_each Approach**

1. **🔧 DRY Principle**: Single module definition instead of multiple copies
2. **📊 Centralized Configuration**: All server configs in one `locals` block
3. **🔄 Easy Scaling**: Add/remove servers by modifying the `servers` map
4. **🎛️ Consistent Structure**: All servers follow the same configuration pattern
5. **📝 Maintainable**: Update monitoring logic in one place

## 📁 **File Structure**

```
multi-monitoring/
├── main.tf           # Main configuration with for_each
├── variables.tf      # Input variables
├── outputs.tf        # Output values
└── README.md         # This file
```

## 🔧 **How It Works**

### **1. Server Configuration Map**

```hcl
locals {
  servers = {
    web-server = {
      environment = "production"
      monitoring = "enhanced"
      # ... web server specific config
    }
    database-server = {
      environment = "production"
      monitoring = "enhanced"
      # ... database server specific config
    }
    # ... more servers
  }
}
```

### **2. Single Module Call with for_each**

```hcl
module "server_monitoring" {
  for_each = local.servers
  source   = "../../modules/ec2-monitoring"
  
  ec2_instance_name = each.key
  # ... pass through config from each.value
}
```

### **3. Dynamic Outputs**

```hcl
output "web_server_monitoring" {
  value = module.server_monitoring["web-server"]
}
```

## 📊 **Server Configurations**

### **Web Server (Enhanced)**
- **Profile**: `web_server`
- **Thresholds**: CPU 70%, Memory 75%
- **Custom Alarms**: Response time, error rate
- **Custom Dashboard**: Web-specific metrics
- **Logs**: Nginx access/error logs

### **Database Server (Enhanced)**
- **Profile**: `database_server`
- **Thresholds**: CPU 60%, Memory 70%
- **Custom Alarms**: Connection count, query latency
- **Custom Dashboard**: Database performance metrics
- **Logs**: MySQL error/slow logs

### **Application Server (Standard)**
- **Profile**: `application_server`
- **Thresholds**: CPU 80%, Memory 80%
- **Custom Alarms**: Application error rate
- **Dashboard**: Default (no custom config)

### **Development Server (Minimal)**
- **Profile**: None (default)
- **Monitoring**: Minimal resources only
- **Dashboard**: Disabled
- **Logs**: Disabled

## 🎨 **Customization Options**

### **Add a New Server**

```hcl
# In locals.servers, add:
cache-server = {
  instance_type = "t3.medium"
  environment  = "production"
  project      = "cache-system"
  service      = "cache-server"
  monitoring   = "enhanced"
  
  monitoring_profiles = {
    profile = "cache_server"
    cache_server = {
      cpu_threshold = 65
      memory_threshold = 80
      # ... cache-specific config
    }
  }
  
  # ... rest of configuration
}
```

### **Override Server Configuration**

```hcl
# In variables.tf, use server_overrides:
variable "server_overrides" {
  default = {
    web-server = {
      cpu_threshold = 75        # Override default 70%
      memory_threshold = 80     # Override default 75%
    }
    database-server = {
      create_dashboard = false  # Disable dashboard for this server
    }
  }
}
```

### **Environment-Specific Configurations**

```hcl
# Use environment_configs variable:
variable "environment_configs" {
  default = {
    production = {
      monitoring_level = "enhanced"
      log_retention_days = 90
      dashboard_period = 300
    }
    development = {
      monitoring_level = "minimal"
      log_retention_days = 30
      dashboard_period = 600
    }
  }
}
```

## 🔍 **Output Examples**

### **All Monitoring Outputs**
```hcl
output "all_monitoring_outputs" {
  value = {
    for server_name, monitoring in module.server_monitoring : server_name => {
      iam_role_arn = monitoring.iam_role_arn
      dashboard_arn = monitoring.dashboard_arn
      # ... all outputs
    }
  }
}
```

### **Specific Server Outputs**
```hcl
output "web_server_monitoring" {
  value = module.server_monitoring["web-server"]
}
```

### **Monitoring Summary**
```hcl
output "monitoring_summary" {
  value = {
    total_servers = length(local.servers)
    enhanced_monitoring_servers = [
      for name, config in local.servers : name if config.monitoring == "enhanced"
    ]
  }
}
```

## 🚀 **Usage Examples**

### **Basic Usage**
```bash
cd examples/ec2-monitoring/multi-monitoring

# Create terraform.tfvars
cat > terraform.tfvars << EOF
vpc_id = "vpc-12345678"
aws_region = "us-west-2"
EOF

# Deploy
terraform init
terraform plan
terraform apply
```

### **With Custom Overrides**
```hcl
# terraform.tfvars
vpc_id = "vpc-12345678"
aws_region = "us-east-1"

server_overrides = {
  web-server = {
    cpu_threshold = 75
    memory_threshold = 80
  }
  dev-server = {
    create_dashboard = true  # Enable dashboard for dev
  }
}
```

### **Environment-Specific Deployment**
```hcl
# production.tfvars
vpc_id = "vpc-prod-123"
aws_region = "us-west-2"

environment_configs = {
  production = {
    monitoring_level = "enhanced"
    log_retention_days = 365
    dashboard_period = 60
  }
}

# development.tfvars
vpc_id = "vpc-dev-456"
aws_region = "us-west-2"

environment_configs = {
  development = {
    monitoring_level = "minimal"
    log_retention_days = 30
    dashboard_period = 600
  }
}
```

## 📈 **Scaling Patterns**

### **Add Multiple Similar Servers**
```hcl
locals {
  # Generate multiple web servers
  web_servers = {
    for i in range(1, 4) : "web-server-${i}" => {
      environment = "production"
      monitoring = "enhanced"
      # ... same config for all web servers
    }
  }
  
  # Generate multiple app servers
  app_servers = {
    for i in range(1, 3) : "app-server-${i}" => {
      environment = "production"
      monitoring = "standard"
      # ... same config for all app servers
    }
  }
  
  # Combine all servers
  servers = merge(local.web_servers, local.app_servers, {
    database-server = local.database_server_config
    dev-server = local.dev_server_config
  })
}
```

### **Environment-Based Server Creation**
```hcl
locals {
  servers = merge(
    var.environment == "production" ? {
      web-server = local.production_web_config
      database-server = local.production_db_config
      app-server = local.production_app_config
    } : {},
    var.environment == "staging" ? {
      web-server = local.staging_web_config
      app-server = local.staging_app_config
    } : {},
    {
      dev-server = local.dev_config  # Always created
    }
  )
}
```

## 🔧 **Best Practices**

1. **📝 Use Descriptive Names**: Server names should clearly indicate their purpose
2. **🏷️ Consistent Tagging**: Use consistent tag patterns across all servers
3. **🔍 Logical Grouping**: Group related servers in the configuration
4. **📊 Monitor Resource Usage**: Use different monitoring levels based on importance
5. **🔄 Version Control**: Keep server configurations in version control

## 🚨 **Troubleshooting**

### **Common Issues**

1. **Module Not Found**: Ensure the module path is correct
2. **Invalid Configuration**: Check that all required variables are provided
3. **Resource Conflicts**: Ensure server names are unique
4. **Output Errors**: Verify output references match the for_each structure

### **Debug Commands**

```bash
# View all server configurations
terraform console
> local.servers

# Check specific server configuration
> local.servers["web-server"]

# Verify module outputs
> module.server_monitoring
```

## 📚 **Next Steps**

- Customize server configurations for your environment
- Add more server types and monitoring profiles
- Implement environment-specific deployments
- Set up CI/CD pipelines for different environments
- Create custom monitoring dashboards and alarms