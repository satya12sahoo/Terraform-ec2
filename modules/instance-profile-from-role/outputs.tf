output "name" {
  description = "Instance profile name"
  value       = aws_iam_instance_profile.this.name
}

output "arn" {
  description = "Instance profile ARN"
  value       = aws_iam_instance_profile.this.arn
}

output "id" {
  description = "Instance profile ID"
  value       = aws_iam_instance_profile.this.id
}

