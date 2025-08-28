resource "aws_iam_instance_profile" "this" {
  role = var.role_name

  name        = var.use_name_prefix ? null : var.name
  name_prefix = var.use_name_prefix ? "${var.name}-" : null
  path        = var.path

  tags = var.tags

  lifecycle {
    create_before_destroy = true
  }
}

