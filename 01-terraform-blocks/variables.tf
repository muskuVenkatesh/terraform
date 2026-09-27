# ==============================================================================
# BLOCK TYPE 3: variable block
# Purpose: Declares configurable input parameters to make Terraform code reusable.
# ==============================================================================

variable "aws_region" {
  description = "AWS region where resources will be created"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Deployment environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "project_name" {
  description = "Project identifier used in resource names and tags"
  type        = string
  default     = "blocks-demo"
}

variable "instance_type" {
  description = "EC2 instance size"
  type        = string
  default     = "t3.micro"
}