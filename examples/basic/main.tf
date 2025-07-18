provider "aws" {
  region = var.aws_region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.0"

  name = "${var.name}-vpc"
  cidr = "10.0.0.0/16"

  azs             = ["${var.aws_region}a"]
  private_subnets = ["10.0.1.0/24"]
  public_subnets  = ["10.0.101.0/24"]

  enable_nat_gateway = true
  enable_vpn_gateway = false

  tags = {
    Environment = "dev"
  }
}

module "security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${var.name}-sg"
  description = "Security group for EC2 instance"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      description = "SSH"
      cidr_blocks = "10.0.0.0/16"
    }
  ]

  egress_rules = ["all-all"]

  tags = {
    Environment = "dev"
  }
}

module "ec2_instance" {
  source = "../../"

  name               = var.name
  instance_count     = 1
  instance_type      = "t3.micro"
  subnet_id          = module.vpc.private_subnets[0]
  security_group_ids = [module.security_group.security_group_id]

  root_block_device = {
    volume_type = "gp3"
    volume_size = 20
    encrypted   = true
  }

  tags = {
    Environment = "dev"
    Project     = "example"
  }
}