variable "aws_region" {
  type        = string
  description = "AWS Region for deployment"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "prod"
}

variable "server_name" {
  type        = string
  description = "Name for web server instance"
  default     = "web-server-v1"
}
