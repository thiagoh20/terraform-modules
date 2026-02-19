variable "project_name" {
  description = "Project name for resource naming"
  type        = string

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name must contain only lowercase letters, numbers, and hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod", "development", "production"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod, development, production."
  }
}

variable "rds_security_group_id" {
  description = "Security Group ID for RDS"
  type        = string

  validation {
    condition     = can(regex("^sg-", var.rds_security_group_id))
    error_message = "RDS Security Group ID must be a valid AWS Security Group ID starting with 'sg-'."
  }
}

variable "subnet_ids" {
  description = "List of subnet IDs for RDS (required - typically private subnets)"
  type        = list(string)

  validation {
    condition     = length(var.subnet_ids) >= 2
    error_message = "At least 2 subnet IDs are required for RDS (for Multi-AZ support)."
  }
}

# Database variables
variable "db_name" {
  description = "Database name"
  type        = string
}

variable "db_username" {
  description = "Database master username"
  type        = string
}

variable "db_password" {
  description = "Database master password"
  type        = string
  sensitive   = true
}

variable "db_instance_class" {
  description = "RDS instance class (db.t3.micro for AWS Free Tier)"
  type        = string
  default     = "db.t3.micro"
}

variable "db_engine_version" {
  description = "PostgreSQL engine version"
  type        = string
  default     = "16.3"
}

variable "db_allocated_storage" {
  description = "Initial allocated storage in GB (20 GB max for AWS Free Tier)"
  type        = number
  default     = 20

  validation {
    condition     = var.db_allocated_storage >= 20 && var.db_allocated_storage <= 65536
    error_message = "Allocated storage must be between 20 and 65536 GB."
  }
}

variable "db_max_allocated_storage" {
  description = "Maximum allocated storage for autoscaling (0 to disable)"
  type        = number
  default     = 0

  validation {
    condition     = var.db_max_allocated_storage == 0 || (var.db_max_allocated_storage >= var.db_allocated_storage && var.db_max_allocated_storage <= 65536)
    error_message = "Max allocated storage must be 0 (disabled) or between allocated_storage and 65536 GB."
  }
}

variable "db_storage_type" {
  description = "Storage type (gp2, gp3, io1, io2, standard)"
  type        = string
  default     = "gp2"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "standard"], var.db_storage_type)
    error_message = "Storage type must be one of: gp2, gp3, io1, io2, standard."
  }
}

variable "db_storage_encrypted" {
  description = "Enable storage encryption (recommended for production)"
  type        = bool
  default     = true
}

variable "db_kms_key_id" {
  description = "KMS key ID for encryption (leave null to use default AWS key)"
  type        = string
  default     = null
}

variable "db_multi_az" {
  description = "Enable Multi-AZ deployment"
  type        = bool
  default     = false
}

variable "db_backup_retention_period" {
  description = "Backup retention period in days (1 day for AWS Free Tier to stay within 20 GB backup limit)"
  type        = number
  default     = 1

  validation {
    condition     = var.db_backup_retention_period >= 0 && var.db_backup_retention_period <= 35
    error_message = "Backup retention period must be between 0 and 35 days."
  }
}

variable "db_backup_window" {
  description = "Backup window"
  type        = string
  default     = "03:00-04:00"
}

variable "db_maintenance_window" {
  description = "Maintenance window"
  type        = string
  default     = "mon:04:00-mon:05:00"
}

variable "db_skip_final_snapshot" {
  description = "Skip final snapshot when destroying (set to false in production)"
  type        = bool
  default     = true
}

variable "db_deletion_protection" {
  description = "Enable deletion protection"
  type        = bool
  default     = false
}

variable "db_enabled_cloudwatch_logs_exports" {
  description = "List of log types to export to CloudWatch"
  type        = list(string)
  default     = ["postgresql"]

  validation {
    condition = alltrue([
      for log in var.db_enabled_cloudwatch_logs_exports : contains(["postgresql", "upgrade"], log)
    ])
    error_message = "CloudWatch log exports must be one of: postgresql, upgrade."
  }
}

variable "db_monitoring_interval" {
  description = "Enhanced monitoring interval in seconds (0, 60, 300, 600, 3600)"
  type        = number
  default     = 0

  validation {
    condition     = contains([0, 60, 300, 600, 3600], var.db_monitoring_interval)
    error_message = "Monitoring interval must be one of: 0, 60, 300, 600, 3600 seconds."
  }
}

variable "db_monitoring_role_arn" {
  description = "IAM role ARN for enhanced monitoring (required if monitoring_interval > 0)"
  type        = string
  default     = null
}

variable "db_performance_insights_enabled" {
  description = "Enable Performance Insights"
  type        = bool
  default     = false
}

variable "db_performance_insights_retention_period" {
  description = "Performance Insights retention period in days (7 or 731)"
  type        = number
  default     = 7

  validation {
    condition     = contains([7, 731], var.db_performance_insights_retention_period)
    error_message = "Performance Insights retention period must be 7 or 731 days."
  }
}

variable "db_parameter_group_name" {
  description = "Name of the DB parameter group to use (leave null for default)"
  type        = string
  default     = null
}

variable "db_auto_minor_version_upgrade" {
  description = "Enable automatic minor version upgrades"
  type        = bool
  default     = true
}

variable "db_apply_immediately" {
  description = "Apply changes immediately (false = during maintenance window)"
  type        = bool
  default     = false
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
