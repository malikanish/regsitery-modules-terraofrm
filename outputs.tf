output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}


output "security_group_id" {
  description = "ID of the security group"
  value       = module.custom_sg.security_group_id
}
