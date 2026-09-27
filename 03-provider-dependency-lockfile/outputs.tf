output "s3_bucket_name" {
  type        = string
  description = "The name of the created S3 bucket"
  value       = aws_s3_bucket.example.id
}

output "aws_region" {
  type        = string
  description = "The AWS region configured"
  value       = var.aws_region
}
