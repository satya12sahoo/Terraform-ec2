plugin "aws" {
  enabled = true
  version = "0.27.0"
  source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

config {
  module = true
  force  = false
}

# Exclude user-inputs directory from validation
# This directory is for user configuration, not module validation
exclude = [
  "user-inputs/**/*"
]