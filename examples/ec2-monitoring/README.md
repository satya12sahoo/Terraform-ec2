# EC2 Monitoring Example

This example demonstrates how to use the EC2 monitoring module to set up comprehensive monitoring for an EC2 instance using AWS CloudWatch agent.

## What This Example Creates

- **EC2 Instance**: A t3.micro instance with monitoring capabilities
- **IAM Role & Policy**: Permissions for CloudWatch agent to send metrics and logs
- **CloudWatch Dashboard**: Pre-configured dashboard with key metrics
- **CloudWatch Alarms**: CPU and memory utilization alarms
- **CloudWatch Log Groups**: For application and system logs
- **Security Group**: Basic security group for SSH access
- **SSM Parameter**: CloudWatch agent configuration

## Prerequisites

- AWS CLI configured with appropriate credentials
- Terraform >= 1.0 installed
- An existing VPC in your AWS account
- At least one subnet in your VPC

## Quick Start

1. **Clone the repository and navigate to this example:**
   ```bash
   cd examples/ec2-monitoring
   ```

2. **Choose your configuration approach:**

   **Option A: Minimal Configuration (Recommended for beginners)**
   ```bash
   cp terraform.tfvars.minimal terraform.tfvars
   # Edit terraform.tfvars and set your VPC ID
   ```

   **Option B: Full Configuration (For advanced users)**
   ```bash
   cp terraform.tfvars.example terraform.tfvars
   # Edit terraform.tfvars and customize as needed
   ```

3. **Edit terraform.tfvars with your values:**
   ```hcl
   # Required
   vpc_id = "vpc-12345678"
   
   # Optional (will use defaults if not specified)
   instance_name = "my-monitoring-server"
   environment   = "production"
   aws_region   = "us-east-1"
   ```

3. **Initialize Terraform:**
   ```bash
   terraform init
   ```

4. **Plan the deployment:**
   ```bash
   terraform plan
   ```

5. **Apply the configuration:**
   ```bash
   terraform apply
   ```

## Configuration Options

### Required Variables

- `vpc_id`: The VPC ID where the EC2 instance will be created

### Optional Variables

- `aws_region`: AWS region (default: us-west-2)
- `instance_name`: Name for the EC2 instance (default: example-monitoring-instance)
- `instance_type`: EC2 instance type (default: t3.micro)
- `ami_id`: AMI ID for the instance (default: Amazon Linux 2)
- `environment`: Environment name for tagging (default: dev)
- `cpu_alarm_threshold`: CPU alarm threshold percentage (default: 80)
- `memory_alarm_threshold`: Memory alarm threshold percentage (default: 80)
- `log_retention_days`: CloudWatch log retention days (default: 30)

### Default Resource Naming

The module automatically generates resource names using this pattern:
- **IAM Role**: `{instance_name}-CloudWatchAgentRole`
- **IAM Policy**: `{instance_name}-CloudWatchAgentPolicy`
- **IAM Instance Profile**: `{instance_name}-CloudWatchAgentProfile`
- **SSM Parameter**: `/cloudwatch-agent/{instance_name}/config`
- **Dashboard**: `{instance_name}-Monitoring-Dashboard`
- **Log Group**: `/aws/ec2/{instance_name}/logs`

You can override any of these names by setting the corresponding variables in your `terraform.tfvars` file.

## What Happens After Deployment

1. **EC2 Instance**: A new EC2 instance is launched with the monitoring IAM role
2. **User Data Script**: Automatically installs and configures the CloudWatch agent
3. **Monitoring Setup**: CloudWatch agent starts collecting metrics and logs
4. **Dashboard**: A CloudWatch dashboard is created with key metrics
5. **Alarms**: CPU and memory alarms are configured

## Monitoring Features

### Metrics Collected
- **System Metrics**: CPU, memory, disk, network
- **Application Metrics**: Custom metrics via CloudWatch agent
- **Logs**: System logs, application logs, security logs

### Alarms
- **CPU Alarm**: Triggers when CPU utilization exceeds threshold
- **Memory Alarm**: Triggers when memory utilization exceeds threshold

### Dashboard
- **EC2 Metrics**: CPU, network in/out
- **System Metrics**: Memory, disk usage
- **Real-time Monitoring**: 5-minute intervals

## Post-Deployment Steps

1. **Verify CloudWatch Agent**: SSH to the instance and check agent status
   ```bash
   systemctl status amazon-cloudwatch-agent
   ```

2. **Check Metrics**: Visit the CloudWatch dashboard to see collected metrics

3. **Test Alarms**: Generate load on the instance to test alarm functionality

4. **Customize Configuration**: Modify the CloudWatch agent configuration as needed

## Cleanup

To remove all resources created by this example:

```bash
terraform destroy
```

## Troubleshooting

### CloudWatch Agent Not Running
- Check IAM role permissions
- Verify SSM parameter exists
- Check agent logs: `/opt/aws/amazon-cloudwatch-agent/logs/`

### No Metrics in CloudWatch
- Ensure agent is running
- Check agent configuration
- Verify IAM permissions
- Check CloudWatch agent logs

### Alarms Not Triggering
- Verify metric collection is working
- Check alarm configuration
- Ensure metrics are being published to CloudWatch

## Security Considerations

- IAM role follows least privilege principle
- Security group restricts SSH access to specified CIDR blocks
- All resources are properly tagged
- CloudWatch agent runs with minimal required permissions

## Cost Optimization

- Use appropriate instance types for your workload
- Monitor CloudWatch costs (first 1M API calls/month are free)
- Adjust log retention periods based on compliance requirements
- Consider using CloudWatch Insights for log analysis

## Support

For issues or questions:
1. Check the CloudWatch agent logs on the instance
2. Verify IAM permissions and policies
3. Review CloudWatch metrics and logs in the AWS console
4. Check Terraform state and logs