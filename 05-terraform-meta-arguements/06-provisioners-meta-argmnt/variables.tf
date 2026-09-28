variable "aws_region" {
  type        = string
  description = "AWS Region for deployment"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"
}

variable "key_name" {
  type        = string
  description = "AWS EC2 Key Pair name for SSH connection"
  default     = "dev-ssh-key"
}
