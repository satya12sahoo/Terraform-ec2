# Multi-Monitoring Example Outputs

# Output all monitoring module outputs
output "all_monitoring_outputs" {
  description = "All outputs from all monitoring modules"
  value = {
    for server_name, monitoring in module.server_monitoring : server_name => {
      iam_role_arn              = monitoring.iam_role_arn
      iam_role_name             = monitoring.iam_role_name
      iam_instance_profile_arn  = monitoring.iam_instance_profile_arn
      iam_instance_profile_name = monitoring.iam_instance_profile_name
      ssm_parameter_arn         = monitoring.ssm_parameter_arn
      ssm_parameter_name        = monitoring.ssm_parameter_name
      dashboard_arn             = monitoring.dashboard_arn
      dashboard_name            = monitoring.dashboard_name
      log_group_arn             = monitoring.log_group_arn
      log_group_name            = monitoring.log_group_name
      cpu_alarm_arn             = monitoring.cpu_alarm_arn
      memory_alarm_arn          = monitoring.memory_alarm_arn
      custom_alarm_arns         = monitoring.custom_alarm_arns
      dashboard_body            = monitoring.dashboard_body
      monitoring_profile_config = monitoring.monitoring_profile_config
    }
  }
}

# Output specific server monitoring information
output "web_server_monitoring" {
  description = "Web server monitoring outputs"
  value = module.server_monitoring["web-server"]
}

output "database_server_monitoring" {
  description = "Database server monitoring outputs"
  value = module.server_monitoring["database-server"]
}

output "app_server_monitoring" {
  description = "Application server monitoring outputs"
  value = module.server_monitoring["app-server"]
}

output "dev_server_monitoring" {
  description = "Development server monitoring outputs"
  value = module.server_monitoring["dev-server"]
}

# Output server configurations
output "server_configurations" {
  description = "All server configurations"
  value = local.servers
}

# Output monitoring summary
output "monitoring_summary" {
  description = "Summary of monitoring configurations"
  value = {
    total_servers = length(local.servers)
    servers_by_environment = {
      for env in distinct([for server in local.servers : server.environment]) : env => [
        for name, config in local.servers : name if config.environment == env
      ]
    }
    servers_by_monitoring_level = {
      for level in distinct([for server in local.servers : server.monitoring]) : level => [
        for name, config in local.servers : name if config.monitoring == level
      ]
    }
    enhanced_monitoring_servers = [
      for name, config in local.servers : name if config.monitoring == "enhanced"
    ]
    standard_monitoring_servers = [
      for name, config in local.servers : name if config.monitoring == "standard"
    ]
    minimal_monitoring_servers = [
      for name, config in local.servers : name if config.monitoring == "minimal"
    ]
  }
}

# Output dashboard URLs
output "dashboard_urls" {
  description = "CloudWatch dashboard URLs for all servers"
  value = {
    for server_name, monitoring in module.server_monitoring : server_name => 
      monitoring.dashboard_arn != null ? 
        "https://${var.aws_region}.console.aws.amazon.com/cloudwatch/home?region=${var.aws_region}#dashboards:name=${monitoring.dashboard_name}" : 
        "No dashboard created"
  }
}

# Output IAM instance profile names for EC2 attachment
output "iam_instance_profiles" {
  description = "IAM instance profile names for EC2 instances"
  value = {
    for server_name, monitoring in module.server_monitoring : server_name => 
      monitoring.iam_instance_profile_name
  }
}