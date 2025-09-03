How to pass most values from a tfvars file

1) Prepare a tfvars file (e.g. `terraform.tfvars`) with your values. Example keys and types:

```hcl
region = "us-east-1"
name   = "my-ec2"

# EC2 basics
ami               = null
instance_type     = "t3.micro"
key_name          = null
subnet_id         = "subnet-xxxxxxxx"
vpc_security_group_ids = ["sg-xxxxxxxx"]
associate_public_ip_address = true
instance_detailed_monitoring = true
tags = {
  Project = "my"
  Env     = "dev"
}

# Monitoring
alarm_name_prefix     = "my-ec2"
create_default_alarms = true

# Either create a new SNS topic
create_sns_topic = true
sns_topic_name   = "my-ec2-alarms"
sns_subscriptions = [
  { protocol = "email", endpoint = "alerts@example.com" }
]

# Or use existing
sns_topic_arn = null

default_alarm_actions = []

# Custom alarms (optional)
custom_alarms = [
  {
    name                = "my-ec2-network-in-high"
    comparison_operator = "GreaterThanOrEqualToThreshold"
    evaluation_periods  = 2
    threshold           = 104857600
    metric_name         = "NetworkIn"
    namespace           = "AWS/EC2"
    period              = 60
    statistic           = "Sum"
    treat_missing_data  = "missing"
  }
]

# CloudWatch Agent via SSM (optional)
enable_cloudwatch_agent = false
create_ssm_association  = true
ssm_document_name       = "AmazonCloudWatch-ManageAgent"
cw_agent_action         = "configure"
cw_agent_config_json    = null
cw_agent_config_ssm_parameter_name = null
```

2) Run Terraform:

```bash
terraform init
terraform plan -var-file=terraform.tfvars
terraform apply -var-file=terraform.tfvars
```

Notes
- If `default_alarm_actions` is empty and you set `create_sns_topic=true`, alarms use the created topic.
- For EC2-related metrics, dimensions are automatically set to `InstanceId = module.ec2.id` unless you override.
- To maximize tfvars-driven config, set all booleans, strings, lists, and objects above in your tfvars.

