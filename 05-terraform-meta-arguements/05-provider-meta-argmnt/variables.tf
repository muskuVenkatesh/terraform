variable "primary_region" {
  type        = string
  description = "Default AWS primary region"
  default     = "us-east-1"
}

variable "secondary_region" {
  type        = string
  description = "Aliased AWS secondary region"
  default     = "us-west-2"
}

variable "environment" {
  type        = string
  description = "Deployment environment"
  default     = "dev"
}
