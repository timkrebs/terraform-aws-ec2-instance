output "instance_ids" {
  description = "List of IDs of instances"
  value       = try(aws_instance.this[*].id, [])
}

output "instance_arns" {
  description = "List of ARNs of instances"
  value       = try(aws_instance.this[*].arn, [])
}

output "instance_availability_zones" {
  description = "List of availability zones of instances"
  value       = try(aws_instance.this[*].availability_zone, [])
}

output "instance_key_names" {
  description = "List of key names of instances"
  value       = try(aws_instance.this[*].key_name, [])
}

output "instance_public_dns" {
  description = "List of public DNS names assigned to the instances"
  value       = try(aws_instance.this[*].public_dns, [])
}

output "instance_public_ips" {
  description = "List of public IP addresses assigned to the instances"
  value       = try(aws_instance.this[*].public_ip, [])
}

output "instance_private_dns" {
  description = "List of private DNS names assigned to the instances"
  value       = try(aws_instance.this[*].private_dns, [])
}

output "instance_private_ips" {
  description = "List of private IP addresses assigned to the instances"
  value       = try(aws_instance.this[*].private_ip, [])
}

output "instance_security_groups" {
  description = "List of associated security groups of instances"
  value       = try(aws_instance.this[*].security_groups, [])
}

output "instance_vpc_security_group_ids" {
  description = "List of associated security groups of instances, if running in non-default VPC"
  value       = try(aws_instance.this[*].vpc_security_group_ids, [])
}

output "instance_subnet_ids" {
  description = "List of IDs of VPC subnets of instances"
  value       = try(aws_instance.this[*].subnet_id, [])
}

output "instance_states" {
  description = "List of instance states of instances"
  value       = try(aws_instance.this[*].instance_state, [])
}

output "eip_ids" {
  description = "List of IDs of Elastic IPs"
  value       = try(aws_eip.this[*].id, [])
}

output "eip_public_ips" {
  description = "List of public IPs of Elastic IPs"
  value       = try(aws_eip.this[*].public_ip, [])
}

output "eip_public_dns" {
  description = "List of public DNS names of Elastic IPs"
  value       = try(aws_eip.this[*].public_dns, [])
}