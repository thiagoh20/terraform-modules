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
  description = "ARN of the SSL certificate in ACM (must be in us-east-1). Optional, if not provided, CloudFront default certificate will be used"
  type        = string
  default     = ""
}


variable "region" {
  description = "The region of the AWS account"
  type        = string
  default     = "us-east-1"
}

variable "bucket_regional_domain_name" {
  description = "The regional domain name of the S3 bucket"
  type        = string
}

variable "hosted_zone_id" {
  description = "The ID of the hosted zone"
  type        = string
  default     = "Z04320191VYF1MHU0W5JV" # hpowercoti
}


variable "s3_bucket_id" {
  description = "The ID of the S3 bucket to use as origin"
  type        = string
}

variable "s3_bucket_domain_name" {
  description = "The domain name of the S3 bucket"
  type        = string
}

variable "origin_access_control_id" {
  description = "The ID of the Origin Access Control"
  type        = string
}
variable "extra_aliases" {
  type        = list(string)
  description = "Lista de dominios adicionales para CloudFront"
  default     = []
}

variable "is_apex_domain" {
  type        = bool
  description = "Set to true when domain_name is the zone apex (e.g. example.com). Route53 forbids CNAME at apex, so an A/ALIAS record is created instead."
  default     = false
}

variable "comment" {
  type        = string
  description = "The comment for the CloudFront distribution"
  default     = ""
}