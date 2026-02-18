# terraform/modules/iam-oidc/variables.tf
variable "github_repository" {
  description = "Repositorio de GitHub en formato 'owner/repo'"
  type        = string
}
variable "oidc_provider_arn" {
  description = "ARN of the existing GitHub OIDC provider"
  type        = string

  validation {
    condition     = can(regex("^arn:aws:iam::[0-9]{12}:oidc-provider/token\\.actions\\.githubusercontent\\.com$", var.oidc_provider_arn))
    error_message = "The OIDC provider ARN must be a valid GitHub Actions OIDC provider ARN."
  }
}
variable "environment" {
  description = "Ambiente de despliegue (dev, staging, prod)"
  type        = string
}

variable "bucket_arn" {
  description = "ARN del bucket de S3"
  type        = string
}

variable "distribution_arn" {
  description = "ARN de la distribución de CloudFront"
  type        = string
}

variable "tags" {
  description = "Tags para aplicar a los recursos"
  type        = map(string)
  default     = {}
}
variable "role_name" {
  description = "Name of the IAM role to create"
  type        = string
}
variable "role_policy_arns" {
  description = "List of IAM policy ARNs to attach to the role"
  type        = list(string)
  default     = []
}

variable "inline_policy_json" {
  description = "JSON string of an inline policy to attach to the role"
  type        = string
  default     = null
}

variable "max_session_duration" {
  description = "Maximum session duration in seconds for the role"
  type        = number
  default     = 3600

  validation {
    condition     = var.max_session_duration >= 900 && var.max_session_duration <= 43200
    error_message = "Max session duration must be between 900 (15 minutes) and 43200 (12 hours) seconds."
  }
}
