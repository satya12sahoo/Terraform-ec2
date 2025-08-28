output "wrapper" {
  description = "Map of outputs of a wrapper."
  value       = module.ec2instance
  # sensitive = false # No sensitive module output found
}
