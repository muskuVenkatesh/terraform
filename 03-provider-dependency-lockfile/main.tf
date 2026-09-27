provider "aws" {
  region = var.aws_region
}

# Example AWS S3 Bucket Resource for Hands-on Practice
resource "aws_s3_bucket" "example" {
  bucket_prefix = var.bucket_prefix

  tags = {
    Environment = "Dev"
    ManagedBy   = "Terraform"
    Tutorial    = "Provider Lock File"
  }
}
