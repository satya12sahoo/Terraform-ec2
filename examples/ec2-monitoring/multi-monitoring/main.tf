# Multi-Monitoring Example
# Demonstrates how to use different monitoring profiles for various server types

# Configure AWS Provider
provider "aws" {
  region = var.aws_region
}

# Web Server with Enhanced Monitoring
module "web_server_monitoring" {
  source = "../../modules/ec2-monitoring"
  
  ec2_instance_name = "web-server"
  aws_region       = var.aws_region
  
  # Use web server monitoring profile
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
      alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
      ok_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
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
      alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
      ok_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
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
  
  tags = {
    Environment = "production"
    Project     = "web-application"
    Service     = "web-server"
    Monitoring  = "enhanced"
  }
}

# Database Server with Database-Focused Monitoring
module "database_server_monitoring" {
  source = "../../modules/ec2-monitoring"
  
  ec2_instance_name = "database-server"
  aws_region       = var.aws_region
  
  # Use database server monitoring profile
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
      alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
      ok_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
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
      alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
      ok_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
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
  
  tags = {
    Environment = "production"
    Project     = "database-system"
    Service     = "database-server"
    Monitoring  = "enhanced"
    DataTier    = "critical"
  }
}

# Application Server with Standard Monitoring
module "app_server_monitoring" {
  source = "../../modules/ec2-monitoring"
  
  ec2_instance_name = "app-server"
  aws_region       = var.aws_region
  
  # Use application server monitoring profile
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
      alarm_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
      ok_actions = var.sns_topic_arn != "" ? [var.sns_topic_arn] : []
    }
  ]
  
  # Use default dashboard (no custom dashboard_config)
  
  tags = {
    Environment = "production"
    Project     = "application-system"
    Service     = "app-server"
    Monitoring  = "standard"
  }
}

# Development Server with Minimal Monitoring
module "dev_server_monitoring" {
  source = "../../modules/ec2-monitoring"
  
  ec2_instance_name = "dev-server"
  aws_region       = var.aws_region
  
  # Minimal monitoring - only essential resources
  create_dashboard = false
  create_log_group = false
  create_cpu_alarm = false
  create_memory_alarm = false
  
  tags = {
    Environment = "development"
    Project     = "development"
    Service     = "dev-server"
    Monitoring  = "minimal"
  }
}