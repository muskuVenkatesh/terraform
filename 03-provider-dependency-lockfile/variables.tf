variable "aws_region" {
  type        = string
  description = "AWS region for resource deployment"
  default     = "us-east-1"
}

variable "bucket_prefix" {
  type        = string
  description = "Prefix for S3 bucket name"
  default     = "lockfile-demo-"
}
