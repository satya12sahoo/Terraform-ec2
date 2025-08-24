# EC2 Wrapper Module

A dynamic Terraform wrapper module for creating multiple EC2 instances with comprehensive configuration options, IAM management, and adaptive resource handling.

## 🎯 Features

- **Dynamic instance creation** - Create multiple instances with different configurations using `for_each` loops
- **Global defaults with instance overrides** - Set common configurations globally and override per instance
- **Adaptive IAM management** - Automatically detects existing resources and creates missing ones
- **Comprehensive configuration** - All base module variables exposed via `tfvars`
- **Monitoring & Logging integration** - Optional CloudWatch monitoring and centralized logging

## 🏗️ System Architecture Flowchart

```mermaid
graph TD
    A[terraform.tfvars] --> B[Wrapper Module]
    
    B --> C{Parse Configurations}
    C --> D[global_settings]
    C --> E[instances map]
    C --> F[IAM Variables]
    C --> G[Security Group Variables]
    C --> H[monitoring object]
    C --> I[logging object]
    
    D --> J[Merge Configurations]
    E --> J
    F --> K{enable_smart_iam?}
    G --> L{create_security_group?}
    H --> M{enable_monitoring_module?}
    I --> N{enable_logging_module?}
    
    %% IAM Logic
    K -->|Yes| O[Adaptive IAM Logic]
    K -->|No| P{existing_iam_role_name?}
    
    O --> Q{Check smart_iam_role_name}
    Q -->|Exists| R[Use Existing Role]
    Q -->|Not Exists| S{Check Profile}
    S -->|Exists| T[Create Role for Profile]
    S -->|Not Exists| U[Create Both Role & Profile]
    
    P -->|Yes| V[Create Instance Profile]
    P -->|No| W{iam_instance_profile?}
    W -->|Yes| X[Use Existing Profile]
    W -->|No| Y[No IAM Resources]
    
    %% Security Group Logic
    L -->|Yes| Z[Create security_group_name]
    L -->|No| AA[Use vpc_security_group_ids]
    
    %% Monitoring Logic
    M -->|Yes| BB[Monitoring Module]
    M -->|No| CC[Skip Monitoring]
    
    BB --> DD[Create monitoring.* resources]
    
    %% Logging Logic
    N -->|Yes| EE[Logging Module]
    N -->|No| FF[Skip Logging]
    
    EE --> GG{logging.create_s3_logging_bucket?}
    GG -->|Yes| HH[Create logging.s3_logging_bucket_name]
    GG -->|No| II{logging.use_existing_s3_bucket?}
    II -->|Yes| JJ[Use logging.existing_s3_bucket_name]
    II -->|No| KK[No S3 Bucket]
    
    EE --> LL[Create logging.* resources]
    
    %% Resource Creation
    R --> MM[Final IAM Config]
    T --> MM
    U --> MM
    V --> MM
    X --> MM
    Y --> MM
    
    Z --> NN[Final Security Group Config]
    AA --> NN
    
    DD --> OO[Monitoring Resources]
    LL --> PP[Logging Resources]
    
    J --> QQ[Base EC2 Module]
    MM --> QQ
    NN --> QQ
    OO --> QQ
    PP --> QQ
    CC --> QQ
    FF --> QQ
    
    QQ --> RR[EC2 Instances Created]
    RR --> SS[Generate Outputs]
    
    %% Styling
    style A fill:#e1f5fe
    style K,L,M,N fill:#ffebee
    style BB,EE fill:#e8f5e8
    style QQ fill:#f3e5f5
    style SS fill:#c8e6c9
```

## ⚙️ Configuration

### **Basic Usage**

```hcl
# terraform.tfvars
aws_region = "us-west-2"
environment = "production"
project_name = "my-project"

# Instance configurations
instances = {
  web-server = {
    name = "web-server-01"
    ami = "ami-12345678"
    instance_type = "t3.micro"
    subnet_id = "subnet-12345678"
    vpc_security_group_ids = ["sg-12345678"]
    tags = {
      Role = "web-server"
    }
  }
  
  db-server = {
    name = "db-server-01"
    ami = "ami-87654321"
    instance_type = "t3.small"
    subnet_id = "subnet-87654321"
    vpc_security_group_ids = ["sg-87654321"]
    tags = {
      Role = "database"
    }
  }
}
```

### **Global Settings**

```hcl
global_settings = {
  enable_monitoring = true
  enable_ebs_optimization = true
  additional_tags = {
    Environment = "production"
    Project = "my-project"
  }
}
```

### **Adaptive IAM (Auto-Detection)**

```hcl
# Automatically detects existing resources and creates missing ones
enable_smart_iam = true
smart_iam_role_name = "ec2-instance-role"
smart_iam_role_tags = {
  Purpose = "EC2 Instance Access"
}
```

### **Security Groups**

```hcl
# Create new security group
create_security_group = true
security_group_name = "web-server-sg"
security_group_tags = {
  Purpose = "Web Server Access"
}

# OR use existing security groups
create_security_group = false
vpc_security_group_ids = ["sg-12345678", "sg-87654321"]
```

### **Monitoring Module**

```hcl
enable_monitoring_module = true
monitoring = {
  create_cloudwatch_agent_role = true
  cloudwatch_agent_role_name = "monitoring-role"
  create_dashboard = true
  dashboard_name = "app-dashboard"
  create_cpu_alarms = true
  cpu_alarm_name = "cpu-alarm"
}
```

### **Logging Module**

```hcl
enable_logging_module = true
logging = {
  # Create new S3 bucket
  create_s3_logging_bucket = true
  s3_logging_bucket_name = "my-logs-bucket"
  
  # OR use existing S3 bucket
  # create_s3_logging_bucket = false
  # use_existing_s3_bucket = true
  # existing_s3_bucket_name = "my-existing-logs-bucket"
  
  create_logging_iam_role = true
  logging_iam_role_name = "logging-role"
}
```

## 📋 Key Variables

| Variable | Type | Description |
|----------|------|-------------|
| `instances` | `map(object)` | Map of instance configurations |
| `global_settings` | `object` | Global settings applied to all instances |
| `enable_smart_iam` | `bool` | Enable adaptive IAM auto-detection |
| `smart_iam_role_name` | `string` | Role name for adaptive IAM |
| `create_security_group` | `bool` | Create new security group |
| `security_group_name` | `string` | Name for new security group |
| `enable_monitoring_module` | `bool` | Enable monitoring module |
| `enable_logging_module` | `bool` | Enable logging module |

## 🚀 Quick Start

1. **Create terraform.tfvars file** with your configuration
2. **Initialize Terraform:**
   ```bash
   terraform init
   ```
3. **Plan deployment:**
   ```bash
   terraform plan
   ```
4. **Apply configuration:**
   ```bash
   terraform apply
   ```

## 📤 Outputs

- `instance_ids` - IDs of created EC2 instances
- `instance_private_ips` - Private IP addresses
- `instance_public_ips` - Public IP addresses
- `iam_role_arn` - ARN of created IAM role
- `security_group_id` - ID of created security group
- `monitoring_enabled` - Whether monitoring is enabled
- `logging_enabled` - Whether logging is enabled

## 📁 Examples

See the `examples/` directory for complete configuration examples:
- `basic-instances.tfvars` - Basic EC2 instances
- `with-monitoring.tfvars` - With monitoring enabled
- `with-logging.tfvars` - With logging enabled
- `adaptive-iam.tfvars` - With adaptive IAM
- `existing-resources.tfvars` - Using existing resources