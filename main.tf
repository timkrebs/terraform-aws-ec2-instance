locals {
  common_tags = merge(
    var.tags,
    {
      Module      = "terraform-aws-ec2-instance"
      ManagedBy   = "Terraform"
      Environment = var.environment
    }
  )
}

data "aws_ami" "this" {
  count = var.ami_id == null ? 1 : 0

  most_recent = true
  owners      = var.ami_owners

  dynamic "filter" {
    for_each = var.ami_filters
    content {
      name   = filter.value.name
      values = filter.value.values
    }
  }
}

resource "aws_instance" "this" {
  count = var.create_instance ? var.instance_count : 0

  ami                    = var.ami_id != null ? var.ami_id : data.aws_ami.this[0].id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  iam_instance_profile = var.iam_instance_profile

  user_data                   = var.user_data
  user_data_base64            = var.user_data_base64
  user_data_replace_on_change = var.user_data_replace_on_change

  monitoring                           = var.enable_monitoring
  associate_public_ip_address          = var.associate_public_ip_address
  disable_api_termination              = var.disable_api_termination
  instance_initiated_shutdown_behavior = var.instance_initiated_shutdown_behavior

  ebs_optimized = var.ebs_optimized

  dynamic "root_block_device" {
    for_each = var.root_block_device != null ? [var.root_block_device] : []
    content {
      volume_type           = lookup(root_block_device.value, "volume_type", null)
      volume_size           = lookup(root_block_device.value, "volume_size", null)
      iops                  = lookup(root_block_device.value, "iops", null)
      throughput            = lookup(root_block_device.value, "throughput", null)
      encrypted             = lookup(root_block_device.value, "encrypted", null)
      kms_key_id            = lookup(root_block_device.value, "kms_key_id", null)
      delete_on_termination = lookup(root_block_device.value, "delete_on_termination", true)
      tags = merge(
        local.common_tags,
        lookup(root_block_device.value, "tags", {}),
        {
          Name = "${var.name}-root-volume-${count.index}"
        }
      )
    }
  }

  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      volume_size           = lookup(ebs_block_device.value, "volume_size", null)
      iops                  = lookup(ebs_block_device.value, "iops", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      kms_key_id            = lookup(ebs_block_device.value, "kms_key_id", null)
      snapshot_id           = lookup(ebs_block_device.value, "snapshot_id", null)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
      tags = merge(
        local.common_tags,
        lookup(ebs_block_device.value, "tags", {}),
        {
          Name = "${var.name}-ebs-${ebs_block_device.key}-${count.index}"
        }
      )
    }
  }

  metadata_options {
    http_endpoint               = var.metadata_options.http_endpoint
    http_tokens                 = var.metadata_options.http_tokens
    http_put_response_hop_limit = var.metadata_options.http_put_response_hop_limit
    instance_metadata_tags      = var.metadata_options.instance_metadata_tags
  }

  tags = merge(
    local.common_tags,
    {
      Name = var.instance_count > 1 ? "${var.name}-${count.index}" : var.name
    }
  )

  volume_tags = merge(
    local.common_tags,
    var.volume_tags
  )

  lifecycle {
    ignore_changes = var.ignore_ami_changes ? [ami] : []
  }
}

resource "aws_eip" "this" {
  count = var.create_instance && var.create_eip ? var.instance_count : 0

  instance = aws_instance.this[count.index].id
  domain   = "vpc"

  tags = merge(
    local.common_tags,
    {
      Name = "${var.name}-eip-${count.index}"
    }
  )
}