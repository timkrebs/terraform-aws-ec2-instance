# AWS EC2 Instance Terraform Module

This module creates AWS EC2 instances with best practices for security, monitoring, and management.

## Features

- Support for multiple instances
- Automatic AMI selection with custom filters
- EBS volume encryption by default
- IMDSv2 enforcement
- Comprehensive tagging strategy
- Optional Elastic IP association
- User data support
- IAM instance profile integration
- Detailed monitoring options

## Usage

### Basic Example

```hcl
module "ec2_instance" {
  source  = "app.terraform.io/YOUR-ORG/ec2-instance/aws"
  version = "1.0.0"

  name               = "my-app-server"
  instance_type      = "t3.micro"
  subnet_id          = "subnet-12345678"
  security_group_ids = ["sg-12345678"]

  tags = {
    Environment = "dev"
    Project     = "my-project"
  }
}
```

### Complete Example

See the [complete example](./examples/complete) for a full working example including VPC, security groups, and IAM roles.

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.0 |
| aws | >= 4.0 |

## Providers

| Name | Version |
|------|---------|
| aws | >= 4.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| `name` | Name to be used on EC2 instance created | `string` | n/a | yes |
| `subnet_id` | The VPC Subnet ID to launch in | `string` | n/a | yes |
| `create_instance` | Whether to create an instance | `bool` | `true` | no |
| `environment` | Environment name (e.g., dev, staging, prod) | `string` | `"dev"` | no |
| `instance_count` | Number of instances to launch | `number` | `1` | no |
| `instance_type` | The type of instance to start | `string` | `"t3.micro"` | no |
| `security_group_ids` | A list of security group IDs to associate with | `list(string)` | `[]` | no |
| `key_name` | Key name of the Key Pair to use for the instance | `string` | `null` | no |
| `ami_id` | ID of AMI to use for the instance | `string` | `null` | no |
| `user_data` | The user data to provide when launching the instance | `string` | `null` | no |
| `enable_monitoring` | If true, the launched EC2 instance will have detailed monitoring enabled | `bool` | `false` | no |
| `ebs_optimized` | If true, the launched EC2 instance will be EBS-optimized | `bool` | `false` | no |
| `root_block_device` | Customize details about the root block device of the instance | `map(any)` | `null` | no |
| `tags` | A mapping of tags to assign to the resource | `map(string)` | `{}` | no |

> **Note**: See [variables.tf](./variables.tf) for the complete list of available inputs.

## Outputs

| Name | Description |
|------|-------------|
| `instance_ids` | List of IDs of instances |
| `instance_arns` | List of ARNs of instances |
| `instance_private_ips` | List of private IP addresses assigned to the instances |
| `instance_public_ips` | List of public IP addresses assigned to the instances |
| `instance_private_dns` | List of private DNS names assigned to the instances |
| `instance_public_dns` | List of public DNS names assigned to the instances |
| `instance_states` | List of instance states of instances |
| `eip_ids` | List of IDs of Elastic IPs |
| `eip_public_ips` | List of public IPs of Elastic IPs |

> **Note**: See [outputs.tf](./outputs.tf) for the complete list of available outputs.

## Security Considerations

- **IMDSv2 is enforced by default** - Protects against SSRF attacks
- **Root and EBS volumes are encrypted by default** - Ensures data at rest encryption
- **Security groups must be explicitly defined** - No default security group is applied
- **Instance termination protection can be enabled** - Prevents accidental termination

## Advanced Configuration Examples

### Multiple Instances with Load Balancing

```hcl
module "ec2_instances" {
  source  = "app.terraform.io/YOUR-ORG/ec2-instance/aws"
  version = "1.0.0"

  name               = "web-server"
  instance_count     = 3
  instance_type      = "t3.medium"
  subnet_id          = "subnet-12345678"
  security_group_ids = ["sg-12345678"]

  tags = {
    Environment = "prod"
    Role        = "web"
  }
}
```

### Instance with Custom AMI and User Data

```hcl
module "ec2_instance" {
  source  = "app.terraform.io/YOUR-ORG/ec2-instance/aws"
  version = "1.0.0"

  name               = "app-server"
  ami_id             = "ami-12345678"
  instance_type      = "m5.large"
  subnet_id          = "subnet-12345678"
  security_group_ids = ["sg-12345678"]
  
  user_data = base64encode(file("${path.module}/user-data.sh"))
  
  iam_instance_profile = aws_iam_instance_profile.app.name
}
```

### Instance with Additional EBS Volumes

```hcl
module "ec2_instance" {
  source  = "app.terraform.io/YOUR-ORG/ec2-instance/aws"
  version = "1.0.0"

  name               = "data-server"
  instance_type      = "r5.xlarge"
  subnet_id          = "subnet-12345678"
  security_group_ids = ["sg-12345678"]
  
  root_block_device = {
    volume_type = "gp3"
    volume_size = 100
    encrypted   = true
  }
  
  ebs_block_devices = {
    data = {
      device_name = "/dev/sdf"
      volume_type = "gp3"
      volume_size = 500
      iops        = 3000
      throughput  = 125
      encrypted   = true
    }
  }
}
```

### Production Instance with Enhanced Security

```hcl
module "ec2_instance" {
  source  = "app.terraform.io/YOUR-ORG/ec2-instance/aws"
  version = "1.0.0"

  name                        = "prod-app-server"
  instance_type               = "m5.2xlarge"
  subnet_id                   = module.vpc.private_subnets[0]
  security_group_ids          = [module.security_group.security_group_id]
  
  enable_monitoring           = true
  disable_api_termination     = true
  ebs_optimized               = true
  
  metadata_options = {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }
  
  tags = {
    Environment = "prod"
    Compliance  = "pci"
    Backup      = "daily"
  }
}
```

## Instance Metadata Service v2 (IMDSv2)

This module enforces IMDSv2 by default for enhanced security. The metadata options can be customized:

```hcl
metadata_options = {
  http_endpoint               = "enabled"  # Enable/disable metadata service
  http_tokens                 = "required"  # Require token for metadata access (IMDSv2)
  http_put_response_hop_limit = 1          # Limit metadata service hops
  instance_metadata_tags      = "disabled"  # Enable/disable instance tags in metadata
}
```

## Module Development

### Running Tests

```bash
cd test/
go test -v -timeout 30m
```

### Pre-commit Hooks

This module uses pre-commit hooks to ensure code quality:

```bash
pre-commit install
pre-commit run --all-files
```

## Migration Guide

### From Community Modules

If migrating from `terraform-aws-modules/ec2-instance/aws`:

1. Update the source to point to this module
2. Review input variable names (most are compatible)
3. Update any deprecated parameters
4. Test in a non-production environment first

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

Apache 2.0 Licensed. See [LICENSE](./LICENSE) for full details.