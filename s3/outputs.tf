output "bucket_id" {
  description = "The ID of the S3 bucket"
  value       = aws_s3_bucket.frontend.id
}

output "bucket_arn" {
  description = "The ARN of the S3 bucket"
  value       = aws_s3_bucket.frontend.arn
}

output "bucket_domain_name" {
  description = "The bucket domain name"
  value       = aws_s3_bucket.frontend.bucket_domain_name
}

output "bucket_regional_domain_name" {
  description = "The bucket regional domain name"
  value       = aws_s3_bucket.frontend.bucket_regional_domain_name
}

# Nota: El Origin Access Control se crea en el módulo CloudFront, no aquí
# output "origin_access_control_id" {
#   description = "The ID of the Origin Access Control"
#   value       = aws_cloudfront_origin_access_control.website.id
# }