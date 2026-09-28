variable "aws_region" {
  type        = string
  description = "AWS Region for deployment"
  default     = "us-east-1"
}

variable "server_count" {
  type        = number
  description = "Number of EC2 web server instances to deploy"
  default     = 3
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"
}

variable "iam_user_names" {
  type        = list(string)
  description = "List of IAM user names to create using count"
  default     = ["dev-alice", "dev-bob", "dev-charlie"]
}

variable "enable_bastion_host" {
  type        = bool
  description = "Controls conditional creation of bastion host (true = create, false = skip)"
  default     = true
}
