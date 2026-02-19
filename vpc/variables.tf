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

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"

  validation {
    condition     = can(cidrhost(var.vpc_cidr, 0))
    error_message = "VPC CIDR must be a valid CIDR block."
  }
}

variable "public_subnet_cidrs" {
  description = "List of CIDR blocks for public subnets (minimum 1 recommended, 2+ for HA)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]

  validation {
    condition     = length(var.public_subnet_cidrs) > 0
    error_message = "At least one public subnet CIDR is required."
  }

  validation {
    condition = alltrue([
      for cidr in var.public_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All public subnet CIDRs must be valid CIDR blocks."
  }
}

variable "private_app_subnet_cidrs" {
  description = "List of CIDR blocks for private app subnets (Lambda, ECS, etc.) - minimum 2 recommended for HA"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]

  validation {
    condition     = length(var.private_app_subnet_cidrs) >= 1
    error_message = "At least 1 private app subnet CIDR is required."
  }

  validation {
    condition = alltrue([
      for cidr in var.private_app_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All private app subnet CIDRs must be valid CIDR blocks."
  }
}

variable "private_data_subnet_cidrs" {
  description = "List of CIDR blocks for private data subnets (RDS, ElastiCache, etc.) - minimum 2 required for RDS Multi-AZ"
  type        = list(string)
  default     = ["10.0.100.0/24", "10.0.200.0/24"]

  validation {
    condition     = length(var.private_data_subnet_cidrs) >= 2
    error_message = "At least 2 private data subnet CIDRs are required (for RDS Multi-AZ support)."
  }

  validation {
    condition = alltrue([
      for cidr in var.private_data_subnet_cidrs : can(cidrhost(cidr, 0))
    ])
    error_message = "All private data subnet CIDRs must be valid CIDR blocks."
  }
}

variable "enable_nat_instance" {
  description = "Enable NAT Instance for private subnets (t2.micro - gratis en Free Tier)"
  type        = bool
  default     = true
}

variable "nat_instance_type" {
  description = "Instance type for NAT Instance (t2.micro para Free Tier)"
  type        = string
  default     = "t2.micro"

  validation {
    condition     = can(regex("^t\\d\\.", var.nat_instance_type))
    error_message = "NAT Instance type should be a t-series instance (e.g., t2.micro, t3.micro)."
  }
}

variable "tags" {
  description = "A map of tags to assign to the resources"
  type        = map(string)
  default     = {}
}
