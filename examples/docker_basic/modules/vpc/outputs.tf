output "vpc_id" {
  value = module.vpc.vpc_id
}

output "security_group_ids" {
  value = [aws_security_group.lambda_security_group.id]
}

output "private_subnet_ids" {
  value = module.vpc.private_subnets
}

output "public_subnet_ids" {
  value = module.vpc.public_subnets
}
