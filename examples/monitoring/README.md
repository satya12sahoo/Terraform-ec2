This example shows how to wire the `modules/monitoring` child module with values passed via a `*.tfvars` file.

Files:
- `main.tf`: Consumes the root EC2 module and attaches the monitoring child module
- `terraform.tfvars`: Provides values for both modules

Usage:
1. Initialize: `terraform init`
2. Plan with tfvars: `terraform plan -var-file=terraform.tfvars`
3. Apply with tfvars: `terraform apply -var-file=terraform.tfvars`

