
resource "random_string" "random_name" {
  length  = 4
  special = false
  upper   = false
}

# Crear el bucket S3
resource "aws_s3_bucket" "frontend" {
  bucket = "${var.bucket_name}-${random_string.random_name.result}"

  tags = var.tags
}

# Recursos de configuración del bucket
resource "aws_s3_bucket_versioning" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "frontend" {
  bucket = aws_s3_bucket.frontend.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
#cifrado de los archivos del bucket
# resource "aws_s3_bucket_server_side_encryption_configuration" "frontend" {
#   bucket = aws_s3_bucket.frontend.id

#   rule {
#     apply_server_side_encryption_by_default {
#       sse_algorithm = "AES256"
#     }
#   }
# }
# Nota: El Origin Access Control se crea en el módulo CloudFront, no aquí