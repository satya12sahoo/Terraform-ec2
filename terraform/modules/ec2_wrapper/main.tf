data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_ami" "al2" {
  count       = var.ami == null ? 1 : 0
  owners      = ["amazon"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
  filter {
    name   = "state"
    values = ["available"]
  }
}

data "aws_default_vpc" "this" {}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_default_vpc.this.id]
  }
}

locals {
  selected_ami    = var.ami != null ? var.ami : (length(data.aws_ami.al2) > 0 ? data.aws_ami.al2[0].id : null)
  selected_subnet = var.subnet_id != null ? var.subnet_id : (length(data.aws_subnets.default.ids) > 0 ? data.aws_subnets.default.ids[0] : null)
  tags_base = merge({
    Name        = var.name
    Environment = "dev"
    Terraform   = "true"
  }, var.tags)
}

resource "aws_security_group" "ssh" {
  count       = length(var.vpc_security_group_ids) == 0 ? 1 : 0
  name        = "${var.name}-ssh"
  description = "Allow SSH"
  vpc_id      = data.aws_default_vpc.this.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags_base
}

resource "aws_instance" "this" {
  ami                         = local.selected_ami
  instance_type               = var.instance_type
  subnet_id                   = local.selected_subnet
  vpc_security_group_ids      = length(var.vpc_security_group_ids) > 0 ? var.vpc_security_group_ids : (aws_security_group.ssh[*].id)
  key_name                    = var.key_name
  iam_instance_profile        = var.iam_instance_profile
  user_data                   = var.user_data
  monitoring                  = true

  root_block_device {
    volume_size = var.volume_size_gb
    volume_type = "gp3"
    delete_on_termination = true
  }

  tags = local.tags_base
}

output "instance_id" {
  value = aws_instance.this.id
}

output "instance_public_ip" {
  value = aws_instance.this.public_ip
}

