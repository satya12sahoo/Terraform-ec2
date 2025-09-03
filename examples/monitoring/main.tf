terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

provider "aws" {
  region = var.region
}

module "ec2" {
  source = "../.."

  create = var.create
  name   = var.name

  region                   = var.region
  ami                      = var.ami
  instance_type            = var.instance_type
  key_name                 = var.key_name
  monitoring               = var.instance_detailed_monitoring
  subnet_id                = var.subnet_id
  vpc_security_group_ids   = var.vpc_security_group_ids
  associate_public_ip_address = var.associate_public_ip_address
  tags                     = var.tags
}

module "monitoring" {
  source = "../../modules/monitoring"

  create               = var.create
  instance_id          = module.ec2.id
  alarm_name_prefix    = var.alarm_name_prefix
  tags                 = var.tags

  # Default alarms
  create_default_alarms = var.create_default_alarms
  default_alarm_actions = var.default_alarm_actions
  default_cpu           = var.default_cpu

  # SNS (either create or use existing)
  create_sns_topic  = var.create_sns_topic
  sns_topic_name    = var.sns_topic_name
  sns_topic_arn     = var.sns_topic_arn
  sns_kms_master_key_id = var.sns_kms_master_key_id
  sns_subscriptions     = var.sns_subscriptions

  # Custom alarms
  alarms = var.custom_alarms

  # CloudWatch Agent via SSM Association
  enable_cloudwatch_agent              = var.enable_cloudwatch_agent
  create_ssm_association               = var.create_ssm_association
  ssm_document_name                    = var.ssm_document_name
  cw_agent_action                      = var.cw_agent_action
  cw_agent_config_json                 = var.cw_agent_config_json
  cw_agent_config_ssm_parameter_name   = var.cw_agent_config_ssm_parameter_name
}

output "instance_id" {
  value = module.ec2.id
}

output "sns_topic_arn" {
  value = module.monitoring.sns_topic_arn
}

