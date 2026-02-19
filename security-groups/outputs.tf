output "rds_security_group_id" {
  description = "Security Group ID for RDS"
  value       = aws_security_group.rds.id
}

output "lambda_security_group_id" {
  description = "Security Group ID for Lambda function"
  value       = aws_security_group.lambda.id
}
