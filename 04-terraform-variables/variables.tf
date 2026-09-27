# ==============================================================================
# 1. BASIC PRIMITIVE TYPES (string, number, bool)
# ==============================================================================

variable "aws_region" {
  type        = string
  description = "AWS Region where resources will be created"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment name (dev, staging, prod)"
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be one of: dev, staging, prod."
  }
}

variable "project_name" {
  type        = string
  description = "Project name used for tagging and resource naming"
  default     = "demo-app"

  validation {
    condition     = length(var.project_name) >= 3 && length(var.project_name) <= 20
    error_message = "Project name must be between 3 and 20 characters long."
  }

  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name can only contain lowercase letters, numbers, and hyphens."
  }
}

variable "instance_count" {
  type        = number
  description = "Number of EC2 instances to launch"
  default     = 2

  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10."
  }
}

variable "enable_monitoring" {
  type        = bool
  description = "Enable detailed CloudWatch monitoring for instances"
  default     = true
}

# ==============================================================================
# 2. COLLECTION TYPES (list, set, map)
# ==============================================================================

variable "availability_zones" {
  type        = list(string)
  description = "List of availability zones for subnet distribution"
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "allowed_ports" {
  type        = set(number)
  description = "Set of unique ingress network ports allowed in security group"
  default     = [80, 443, 22]
}

variable "instance_types" {
  type        = map(string)
  description = "Map of EC2 instance types per environment"
  default = {
    dev     = "t3.micro"
    staging = "t3.small"
    prod    = "t3.medium"
  }
}

variable "common_tags" {
  type        = map(string)
  description = "Map of standard tags applied to all infrastructure resources"
  default = {
    ManagedBy = "Terraform"
    Owner     = "DevOps-Team"
  }
}

# ==============================================================================
# 3. STRUCTURAL TYPES (object, map(object), optional attributes)
# ==============================================================================

variable "database_config" {
  type = object({
    name              = string
    port              = number
    allocated_storage = number
    multi_az          = optional(bool, false)
    backup_retention  = optional(number, 7)
  })
  description = "Database configuration object with default optional attributes"
  default = {
    name              = "appdb"
    port              = 5432
    allocated_storage = 20
  }
}

variable "subnet_configs" {
  type = map(object({
    cidr_block = string
    public     = bool
    az         = string
  }))
  description = "Map of subnet configuration objects"
  default = {
    web_sub_a = {
      cidr_block = "10.0.1.0/24"
      public     = true
      az         = "us-east-1a"
    }
    app_sub_b = {
      cidr_block = "10.0.2.0/24"
      public     = false
      az         = "us-east-1b"
    }
  }
}

# ==============================================================================
# 4. SENSITIVE & REQUIRED VARIABLES
# ==============================================================================

variable "db_password" {
  type        = string
  description = "Administrator password for database (Sensitive input)"
  sensitive   = true
  # Required variable: No default value provided!
}

variable "api_secret_key" {
  type        = string
  description = "API secret key for external integration (Sensitive input)"
  sensitive   = true
  default     = "default-secret-key-change-me"
}
