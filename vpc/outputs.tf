output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "vpc_cidr_block" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.main.cidr_block
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_app_subnet_ids" {
  description = "List of private app subnet IDs (for Lambda, ECS, etc.)"
  value       = aws_subnet.private_app[*].id
}

output "private_data_subnet_ids" {
  description = "List of private data subnet IDs (for RDS, ElastiCache, etc.)"
  value       = aws_subnet.private_data[*].id
}

# Alias para compatibilidad hacia atrás
output "private_subnet_ids" {
  description = "List of private data subnet IDs (alias for private_data_subnet_ids)"
  value       = aws_subnet.private_data[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.main.id
}

output "nat_instance_id" {
  description = "ID of the NAT Instance (if enabled)"
  value       = var.enable_nat_instance ? aws_instance.nat[0].id : null
}

output "nat_instance_private_ip" {
  description = "Private IP of the NAT Instance (if enabled)"
  value       = var.enable_nat_instance ? aws_instance.nat[0].private_ip : null
}

output "nat_instance_public_ip" {
  description = "Public IP (Elastic IP) of the NAT Instance (if enabled)"
  value       = var.enable_nat_instance ? aws_eip.nat_instance[0].public_ip : null
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_app_route_table_id" {
  description = "ID of the private app route table"
  value       = aws_route_table.private_app.id
}

output "private_data_route_table_id" {
  description = "ID of the private data route table"
  value       = aws_route_table.private_data.id
}
