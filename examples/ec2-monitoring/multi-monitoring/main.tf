# Multi-Monitoring Example using for_each
# Demonstrates how to use different monitoring profiles for various server types

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Define server configurations with monitoring profiles
locals {
  servers = {
    web-server = {
      instance_type = "t3.medium"
      environment  = "production"
      project      = "web-application"
      service      = "web-server"
      monitoring   = "enhanced"
      
      # Web server monitoring profile
      monitoring_profiles = {
        profile = "web_server"
        web_server = {
          cpu_threshold = 70
          memory_threshold = 75
          disk_threshold = 80
          response_time_threshold = 1000
          custom_metrics = ["http_requests_per_sec", "error_rate"]
        }
      }
      
      # Custom alarms for web server
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
        },
        {
          name = "high-error-rate"
          description = "HTTP error rate is too high"
          metric_name = "ErrorRate"
          namespace = "WebServer"
          comparison_operator = "GreaterThanThreshold"
          threshold = 5
          period = 300
          evaluation_periods = 2
          statistic = "Average"
          dimensions = {
            InstanceId = "web-server"
            Service = "web"
          }
        }
      ]
      
      # Custom dashboard for web server
      dashboard_config = {
        widgets = [
          {
            type   = "metric"
            x      = 0
            y      = 0
            width  = 12
            height = 6
            properties = {
              metrics = [
                ["AWS/EC2", "CPUUtilization", "InstanceId", "web-server"],
                [".", "NetworkIn", ".", "."],
                [".", "NetworkOut", ".", "."]
              ]
              period = 300
              stat   = "Average"
              region = var.aws_region
              title  = "Web Server System Metrics"
              view   = "timeSeries"
            }
          },
          {
            type   = "metric"
            x      = 12
            y      = 0
            width  = 12
            height = 6
            properties = {
              metrics = [
                ["CWAgent", "mem_used_percent", "InstanceId", "web-server"],
                [".", "disk_used_percent", ".", "."]
              ]
              period = 300
              stat   = "Average"
              region = var.aws_region
              title  = "Web Server Resource Usage"
              view   = "timeSeries"
            }
          },
          {
            type   = "metric"
            x      = 0
            y      = 6
            width  = 24
            height = 6
            properties = {
              metrics = [
                ["WebServer", "ResponseTime", "InstanceId", "web-server"],
                [".", "RequestCount", ".", "."],
                [".", "ErrorRate", ".", "."]
              ]
              period = 300
              stat   = "Average"
              region = var.aws_region
              title  = "Web Server Performance Metrics"
              view   = "timeSeries"
            }
          }
        ]
      }
      
      # Enhanced CloudWatch agent config for web server
      cloudwatch_agent_config = jsonencode({
        "agent": {
          "metrics_collection_interval": 30,
          "run_as_user": "root"
        },
        "logs": {
          "logs_collected": {
            "files": {
              "collect_list": [
                {
                  "file_path": "/var/log/nginx/access.log",
                  "log_group_name": "/aws/ec2/web-server/nginx/access",
                  "log_stream_name": "{instance_id}",
                  "timezone": "UTC"
                },
                {
                  "file_path": "/var/log/nginx/error.log",
                  "log_group_name": "/aws/ec2/web-server/nginx/error",
                  "log_stream_name": "{instance_id}",
                  "timezone": "UTC"
                }
              ]
            }
          }
        },
        "metrics": {
          "metrics_collected": {
            "cpu": {
              "measurement": ["cpu_usage_idle", "cpu_usage_user", "cpu_usage_system"],
              "metrics_collection_interval": 30
            },
            "mem": {
              "measurement": ["mem_used_percent"],
              "metrics_collection_interval": 30
            }
          }
        }
      })
    }
    
    database-server = {
      instance_type = "t3.large"
      environment  = "production"
      project      = "database-system"
      service      = "database-server"
      monitoring   = "enhanced"
      data_tier    = "critical"
      
      # Database server monitoring profile
      monitoring_profiles = {
        profile = "database_server"
        database_server = {
          cpu_threshold = 60
          memory_threshold = 70
          disk_threshold = 85
          connection_threshold = 100
          custom_metrics = ["query_performance", "connection_pool", "cache_hit_ratio"]
        }
      }
      
      # Custom alarms for database server
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
        },
        {
          name = "high-query-latency"
          description = "Database query latency is too high"
          metric_name = "QueryLatency"
          namespace = "Database"
          comparison_operator = "GreaterThanThreshold"
          threshold = 500
          period = 300
          evaluation_periods = 2
          statistic = "Average"
          dimensions = {
            InstanceId = "database-server"
            Service = "database"
          }
        }
      ]
      
      # Custom dashboard for database server
      dashboard_config = {
        widgets = [
          {
            type   = "metric"
            x      = 0
            y      = 0
            width  = 12
            height = 6
            properties = {
              metrics = [
                ["AWS/EC2", "CPUUtilization", "InstanceId", "database-server"],
                [".", "NetworkIn", ".", "."],
                [".", "NetworkOut", ".", "."]
              ]
              period = 300
              stat   = "Average"
              region = var.aws_region
              title  = "Database Server System Metrics"
              view   = "timeSeries"
            }
          },
          {
            type   = "metric"
            x      = 12
            y      = 0
            width  = 12
            height = 6
            properties = {
              metrics = [
                ["CWAgent", "mem_used_percent", "InstanceId", "database-server"],
                [".", "disk_used_percent", ".", "."]
              ]
              period = 300
              stat   = "Average"
              region = var.aws_region
              title  = "Database Server Resource Usage"
              view   = "timeSeries"
            }
          },
          {
            type   = "metric"
            x      = 0
            y      = 6
            width  = 24
            height = 6
            properties = {
              metrics = [
                ["Database", "DatabaseConnections", "InstanceId", "database-server"],
                [".", "QueryLatency", ".", "."],
                [".", "CacheHitRatio", ".", "."]
              ]
              period = 300
              stat   = "Average"
              region = var.aws_region
              title  = "Database Performance Metrics"
              view   = "timeSeries"
            }
          }
        ]
      }
      
      # Enhanced CloudWatch agent config for database server
      cloudwatch_agent_config = jsonencode({
        "agent": {
          "metrics_collection_interval": 30,
          "run_as_user": "root"
        },
        "logs": {
          "logs_collected": {
            "files": {
              "collect_list": [
                {
                  "file_path": "/var/log/mysql/error.log",
                  "log_group_name": "/aws/ec2/database-server/mysql/error",
                  "log_stream_name": "{instance_id}",
                  "timezone": "UTC"
                },
                {
                  "file_path": "/var/log/mysql/slow.log",
                  "log_group_name": "/aws/ec2/database-server/mysql/slow",
                  "log_stream_name": "{instance_id}",
                  "timezone": "UTC"
                }
              ]
            }
          }
        },
        "metrics": {
          "metrics_collected": {
            "disk": {
              "measurement": ["used_percent", "io_time", "read_time", "write_time"],
              "metrics_collection_interval": 30,
              "resources": ["*"]
            },
            "mem": {
              "measurement": ["mem_used_percent", "mem_available", "mem_cached"],
              "metrics_collection_interval": 30
            }
          }
        }
      })
    }
    
    app-server = {
      instance_type = "t3.medium"
      environment  = "production"
      project      = "application-system"
      service      = "app-server"
      monitoring   = "standard"
      
      # Application server monitoring profile
      monitoring_profiles = {
        profile = "application_server"
        application_server = {
          cpu_threshold = 80
          memory_threshold = 80
          disk_threshold = 75
          error_rate_threshold = 5
          custom_metrics = ["application_errors", "response_time"]
        }
      }
      
      # Custom alarms for application server
      custom_alarms = [
        {
          name = "high-error-rate"
          description = "Application error rate is too high"
          metric_name = "ApplicationErrors"
          namespace = "Application"
          comparison_operator = "GreaterThanThreshold"
          threshold = 5
          period = 300
          evaluation_periods = 2
          statistic = "Average"
          dimensions = {
            InstanceId = "app-server"
            Service = "application"
          }
        }
      ]
      
      # Use default dashboard (no custom dashboard_config)
      dashboard_config = null
      
      # Standard CloudWatch agent config
      cloudwatch_agent_config = null
    }
    
    dev-server = {
      instance_type = "t3.micro"
      environment  = "development"
      project      = "development"
      service      = "dev-server"
      monitoring   = "minimal"
      
      # No monitoring profiles for dev server
      monitoring_profiles = null
      
      # No custom alarms for dev server
      custom_alarms = []
      
      # No custom dashboard for dev server
      dashboard_config = null
      
      # Standard CloudWatch agent config
      cloudwatch_agent_config = null
      
      # Minimal monitoring - only essential resources
      create_dashboard = false
      create_log_group = false
      create_cpu_alarm = false
      create_memory_alarm = false
    }
  }
}

# Create monitoring for all servers using for_each
module "server_monitoring" {
  for_each = local.servers
  source   = "../../modules/ec2-monitoring"
  
  ec2_instance_name = each.key
  aws_region       = var.aws_region
  
  # Pass through all configuration from the server definition
  monitoring_profiles = each.value.monitoring_profiles
  custom_alarms      = each.value.custom_alarms
  dashboard_config   = each.value.dashboard_config
  cloudwatch_agent_config = each.value.cloudwatch_agent_config
  
  # Conditional resource creation for dev server
  create_dashboard = lookup(each.value, "create_dashboard", true)
  create_log_group = lookup(each.value, "create_log_group", true)
  create_cpu_alarm = lookup(each.value, "create_cpu_alarm", true)
  create_memory_alarm = lookup(each.value, "create_memory_alarm", true)
  
  # Tags
  tags = merge({
    Environment = each.value.environment
    Project     = each.value.project
    Service     = each.value.service
    Monitoring  = each.value.monitoring
  }, lookup(each.value, "data_tier", null) != null ? {
    DataTier = each.value.data_tier
  } : {})
}