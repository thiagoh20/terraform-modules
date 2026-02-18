# terraform/modules/cloudfront/variables.tf
variable "domain_name" {
  description = "Nombre de dominio del bucket de S3"
  type        = string
}

variable "bucket_id" {
  description = "ID del bucket de S3"
  type        = string
}

variable "environment" {
  description = "Ambiente de despliegue (dev, staging, prod)"
  type        = string
}

variable "tags" {
  description = "Tags para aplicar a los recursos"
  type        = map(string)
  default     = {}
}
variable "certificate_arn" {
  description = "ARN of the SSL certificate in ACM (must be in us-east-1)"
  type        = string
}