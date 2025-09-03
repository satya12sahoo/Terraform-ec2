terraform {
  required_version = ">= 1.5.7"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.0"
    }
  }
}

locals {
  create = var.create

  topic_arn = var.create_sns_topic ? aws_sns_topic.this[0].arn : var.sns_topic_arn

  default_alarm_actions = length(var.default_alarm_actions) > 0 ? var.default_alarm_actions : (
    local.topic_arn != null ? [local.topic_arn] : []
  )

  merged_alarms = [for idx, a in var.alarms : merge(a, {
    name = coalesce(a.name, format("%s-%s", var.alarm_name_prefix, idx))
    alarm_actions = coalesce(a.alarm_actions, local.default_alarm_actions)
    ok_actions    = coalesce(a.ok_actions, local.default_alarm_actions)
    insufficient_data_actions = coalesce(a.insufficient_data_actions, [])
    dimensions = a.dimensions == null && a.namespace == "AWS/EC2" ? {
      InstanceId = var.instance_id
    } : (
      a.dimensions == null ? {} : a.dimensions
    )
  })]
}

resource "aws_sns_topic" "this" {
  count = local.create && var.create_sns_topic ? 1 : 0

  name              = coalesce(var.sns_topic_name, format("%s-alarms", var.alarm_name_prefix))
  kms_master_key_id = var.sns_kms_master_key_id
  tags              = var.tags
}

resource "aws_sns_topic_subscription" "this" {
  for_each = local.create && var.create_sns_topic ? { for s in var.sns_subscriptions : format("%s:%s", s.protocol, s.endpoint) => s } : {}

  topic_arn = aws_sns_topic.this[0].arn
  protocol  = each.value.protocol
  endpoint  = each.value.endpoint
}

resource "aws_cloudwatch_metric_alarm" "default" {
  for_each = local.create && var.create_default_alarms ? {
    "cpu_high" = {
      alarm_name          = format("%s-cpu-high", var.alarm_name_prefix)
      comparison_operator = var.default_cpu.comparison_operator
      evaluation_periods  = var.default_cpu.evaluation_periods
      threshold           = var.default_cpu.threshold
      period              = var.default_cpu.period
      statistic           = var.default_cpu.statistic
      treat_missing_data  = var.default_cpu.treat_missing_data
      metric_name         = "CPUUtilization"
      namespace           = "AWS/EC2"
      dimensions          = { InstanceId = var.instance_id }
    }
    "status_check" = {
      alarm_name          = format("%s-status-check", var.alarm_name_prefix)
      comparison_operator = "GreaterThanOrEqualToThreshold"
      evaluation_periods  = 1
      threshold           = 1
      period              = 60
      statistic           = "Maximum"
      treat_missing_data  = "missing"
      metric_name         = "StatusCheckFailed_System"
      namespace           = "AWS/EC2"
      dimensions          = { InstanceId = var.instance_id }
    }
  } : {}

  alarm_name          = each.value.alarm_name
  comparison_operator = each.value.comparison_operator
  evaluation_periods  = each.value.evaluation_periods
  threshold           = each.value.threshold
  metric_name         = each.value.metric_name
  namespace           = each.value.namespace
  period              = each.value.period
  statistic           = each.value.statistic
  treat_missing_data  = each.value.treat_missing_data
  alarm_actions       = local.default_alarm_actions
  ok_actions          = local.default_alarm_actions
  dimensions          = each.value.dimensions
  tags                = var.tags
}

resource "aws_cloudwatch_metric_alarm" "custom" {
  for_each = local.create ? { for a in local.merged_alarms : a.name => a } : {}

  alarm_name                = each.value.name
  comparison_operator       = each.value.comparison_operator
  evaluation_periods        = each.value.evaluation_periods
  threshold                 = each.value.threshold
  metric_name               = each.value.metric_name
  namespace                 = each.value.namespace
  period                    = each.value.period
  statistic                 = try(each.value.statistic, null)
  extended_statistic        = try(each.value.extended_statistic, null)
  datapoints_to_alarm       = try(each.value.datapoints_to_alarm, null)
  treat_missing_data        = try(each.value.treat_missing_data, null)
  alarm_description         = try(each.value.alarm_description, null)
  unit                      = try(each.value.unit, null)
  alarm_actions             = try(each.value.alarm_actions, local.default_alarm_actions)
  ok_actions                = try(each.value.ok_actions, local.default_alarm_actions)
  insufficient_data_actions = try(each.value.insufficient_data_actions, null)
  dimensions                = try(each.value.dimensions, {})
  tags                      = var.tags
}

# Optional: Manage CloudWatch Agent via SSM Association
resource "aws_ssm_association" "cw_agent" {
  count = local.create && var.enable_cloudwatch_agent && var.create_ssm_association ? 1 : 0

  name = var.ssm_document_name

  targets {
    key    = "InstanceIds"
    values = [var.instance_id]
  }

  parameters = merge(
    var.cw_agent_config_json != null ? {
      cw_agent_config = [var.cw_agent_config_json]
    } : {},
    var.cw_agent_config_ssm_parameter_name != null ? {
      cw_agent_config_ssm_parameter_store_name = [var.cw_agent_config_ssm_parameter_name]
    } : {},
    {
      action = [var.cw_agent_action]
    },
  )
}

