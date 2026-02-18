
# Si el bucket no existe, debe crearse manualmente o cambiar esto a resource
data "aws_s3_bucket" "frontend" {
  bucket = "${var.bucket_name}-${random_string.random_name.result}"
}

resource "random_string" "random_name" {
  length  = 4
  special = false
  upper   = false
}
# Recursos de configuración del bucket (se aplican al bucket existente)
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = data.aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = data.aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
#cifrado de los archivos del bucket
# resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
#   bucket = data.aws_s3_bucket.frontend.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
resource "aws_cloudfront_origin_access_control" "website" {
  name                              = "${var.bucket_name}-oac"
  description                       = "Cerrar la puerta de entrada a ${var.bucket_name}"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}