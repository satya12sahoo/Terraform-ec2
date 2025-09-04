# EC2 Monitoring Module

This Terraform module provides comprehensive monitoring for EC2 instances using AWS CloudWatch agent. It creates all necessary resources to monitor EC2 instances including IAM roles, CloudWatch dashboards, alarms, and log groups.

## Features

- **IAM Role & Policy**: Creates IAM role with necessary permissions for CloudWatch agent
- **CloudWatch Agent Configuration**: SSM Parameter Store configuration for the agent
- **Monitoring Dashboard**: Pre-configured CloudWatch dashboard with key metrics
- **Log Management**: CloudWatch log groups for application and system logs
- **Alerts**: Configurable alarms for CPU and memory utilization
- **Flexible Configuration**: All resources are optional and configurable

## Usage

### Basic Usage (Minimal Configuration)

The module provides sensible defaults for all resources. You only need to specify the EC2 instance name:

```hcl
module "ec2_monitoring" {
  source = "./modules/ec2-monitoring"
  
  ec2_instance_name = "my-ec2-instance"
  
  tags = {
    Environment = "production"
    Project     = "monitoring"
  }
}
```

**Default Resource Names:**
- IAM Role: `{ec2_instance_name}-CloudWatchAgentRole`
- IAM Policy: `{ec2_instance_name}-CloudWatchAgentPolicy`
- IAM Instance Profile: `{ec2_instance_name}-CloudWatchAgentProfile`
- SSM Parameter: `/cloudwatch-agent/{ec2_instance_name}/config`
- Dashboard: `{ec2_instance_name}-Monitoring-Dashboard`
- Log Group: `/aws/ec2/{ec2_instance_name}/logs`

### Advanced Usage with Custom Configuration

```hcl
module "ec2_monitoring" {
  source = "./modules/ec2-monitoring"
  
  ec2_instance_name = "my-ec2-instance"
  aws_region       = "us-east-1"
  
  # Custom alarm thresholds
  cpu_alarm_threshold    = 90
  memory_alarm_threshold = 85
  
  # Custom log retention
  log_retention_days = 90
  
  # Custom dashboard name
  dashboard_name = "My-Custom-Dashboard"
  
  # SNS topic for alarms
  alarm_actions = ["arn:aws:sns:us-east-1:123456789012:my-sns-topic"]
  
  tags = {
    Environment = "production"
    Project     = "monitoring"
    Owner       = "devops-team"
  }
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| ec2_instance_name | Name of the EC2 instance to monitor | `string` | n/a | yes |
| aws_region | AWS region for the monitoring resources | `string` | `"us-west-2"` | no |
| create_iam_role | Whether to create IAM role for CloudWatch agent | `bool` | `true` | no |
| iam_role_name | Name of the IAM role for CloudWatch agent | `string` | `null` (auto-generated) | no |
| iam_role_path | Path for the IAM role | `string` | `"/"` | no |
| iam_policy_name | Name of the IAM policy for CloudWatch agent | `string` | `null` (auto-generated) | no |
| iam_policy_path | Path for the IAM policy | `string` | `"/"` | no |
| iam_instance_profile_name | Name of the IAM instance profile | `string` | `null` (auto-generated) | no |
| create_ssm_parameter | Whether to create SSM parameter for CloudWatch agent configuration | `bool` | `true` | no |
| ssm_parameter_name | Name of the SSM parameter for CloudWatch agent configuration | `string` | `null` (auto-generated) | no |
| ssm_parameter_tier | Tier for the SSM parameter | `string` | `"Standard"` | no |
| cloudwatch_agent_config | CloudWatch agent configuration JSON | `string` | Comprehensive default config | no |
| create_dashboard | Whether to create CloudWatch dashboard | `bool` | `true` | no |
| dashboard_name | Name of the CloudWatch dashboard | `string` | `null` (auto-generated) | no |
| create_log_group | Whether to create CloudWatch log group | `bool` | `true` | no |
| log_group_name | Name of the CloudWatch log group | `string` | `null` (auto-generated) | no |
| create_cpu_alarm | Whether to create CPU utilization alarm | `bool` | `true` | no |
| create_memory_alarm | Whether to create memory utilization alarm | `bool` | `true` | no |
| cpu_alarm_threshold | CPU utilization threshold for alarm (percentage) | `number` | `80` | no |
| memory_alarm_threshold | Memory utilization threshold for alarm (percentage) | `number` | `80` | no |
| log_retention_days | Number of days to retain CloudWatch logs | `number` | `30` | no |
| alarm_actions | List of ARNs to notify when alarm is triggered | `list(string)` | `[]` | no |
| ok_actions | List of ARNs to notify when alarm is cleared | `list(string)` | `[]` | no |
| tags | A map of tags to assign to the resources | `map(string)` | `{}` | no |

## Outputs

| Name | Description |
|------|-------------|
| iam_role_arn | ARN of the CloudWatch agent IAM role |
| iam_role_name | Name of the CloudWatch agent IAM role |
| iam_instance_profile_arn | ARN of the CloudWatch agent IAM instance profile |
| iam_instance_profile_name | Name of the CloudWatch agent IAM instance profile |
| ssm_parameter_arn | ARN of the CloudWatch agent configuration SSM parameter |
| ssm_parameter_name | Name of the CloudWatch agent configuration SSM parameter |
| dashboard_arn | ARN of the CloudWatch monitoring dashboard |
| dashboard_name | Name of the CloudWatch monitoring dashboard |
| log_group_arn | ARN of the CloudWatch log group |
| log_group_name | Name of the CloudWatch log group |
| cpu_alarm_arn | ARN of the CPU utilization CloudWatch alarm |
| memory_alarm_arn | ARN of the memory utilization CloudWatch alarm |
| cloudwatch_agent_config | The CloudWatch agent configuration JSON |

## CloudWatch Agent Installation

After applying this Terraform configuration, you'll need to install the CloudWatch agent on your EC2 instance. Here's a sample user data script:

```bash
#!/bin/bash
# Install CloudWatch agent
yum install -y amazon-cloudwatch-agent

# Download configuration from SSM Parameter Store
aws ssm get-parameter --name "/cloudwatch-agent/config" --region us-west-2 --query "Parameter.Value" --output text > /opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Start CloudWatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -s -c file:/opt/aws/amazon-cloudwatch-agent/etc/amazon-cloudwatch-agent.json

# Enable CloudWatch agent service
systemctl enable amazon-cloudwatch-agent
systemctl start amazon-cloudwatch-agent
```

## Monitoring Metrics

The CloudWatch agent will collect the following metrics:

- **CPU Metrics**: Usage idle, iowait, user, system
- **Memory Metrics**: Used percentage
- **Disk Metrics**: Used percentage, I/O time
- **Network Metrics**: TCP connections
- **System Metrics**: Swap usage

## Log Collection

The agent is configured to collect logs from:
- `/var/log/messages`
- `/var/log/secure`

## Security

- IAM role follows least privilege principle
- Only necessary permissions for CloudWatch agent operation
- All resources are tagged for cost tracking and management

## Cost Considerations

- CloudWatch metrics: First 1 million API requests per month are free
- CloudWatch logs: First 5 GB ingested per month is free
- CloudWatch dashboards: $3.00 per dashboard per month
- CloudWatch alarms: $0.10 per alarm metric per month

## Examples

See the `examples/` directory for complete working examples.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This module is licensed under the same license as the parent repository.