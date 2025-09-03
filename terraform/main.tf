module "ec2" {
  source = "./modules/ec2_wrapper"

  name                 = var.instance_name
  instance_type        = var.instance_type
  ami                  = var.ami
  subnet_id            = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  key_name             = var.key_name
  iam_instance_profile = var.iam_instance_profile
  user_data            = var.user_data
  volume_size_gb       = var.volume_size_gb
  tags                 = var.tags
}

module "monitoring" {
  source = "./modules/monitoring"

  name_prefix          = var.instance_name
  instance_id          = module.ec2.instance_id
  alarm_cpu_threshold  = var.alarm_cpu_threshold
  alarm_eval_periods   = var.alarm_eval_periods
  alarm_period_seconds = var.alarm_period_seconds
  sns_topic_arn        = var.sns_topic_arn
}

output "instance_id" {
  value       = module.ec2.instance_id
  description = "ID of the EC2 instance"
}

output "instance_public_ip" {
  value       = module.ec2.instance_public_ip
  description = "Public IP of the EC2 instance (if assigned)"
}

