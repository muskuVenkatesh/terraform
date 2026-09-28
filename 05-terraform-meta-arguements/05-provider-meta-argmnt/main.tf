# ==============================================================================
# Terraform Meta-Argument: `provider`
# Hands-On Practice & Implementation
# ==============================================================================

# Random bucket name suffix
resource "random_pet" "bucket_suffix" {
  length    = 2
  separator = "-"
}

# ------------------------------------------------------------------------------
# 1. Default Provider (Primary Region: us-east-1)
# ------------------------------------------------------------------------------
# No `provider` meta-argument specified -> defaults to un-aliased `provider "aws"`
resource "aws_s3_bucket" "primary_bucket" {
  bucket = "primary-app-bucket-${var.primary_region}-${random_pet.bucket_suffix.id}"

  tags = {
    Name        = "Primary Storage"
    Region      = var.primary_region
    Environment = var.environment
  }
}

resource "local_file" "primary_region_config" {
  content  = "Primary Region Deployment Config: ${var.primary_region}"
  filename = "${path.module}/generated_regions/primary_us_east_1.txt"
}

# ------------------------------------------------------------------------------
# 2. Aliased Provider (Secondary Region: us-west-2)
# ------------------------------------------------------------------------------
# Explicitly uses `provider = aws.us_west_2`
resource "aws_s3_bucket" "secondary_bucket" {
  provider = aws.us_west_2

  bucket = "secondary-app-bucket-${var.secondary_region}-${random_pet.bucket_suffix.id}"

  tags = {
    Name        = "Disaster Recovery Storage"
    Region      = var.secondary_region
    Environment = var.environment
  }
}

resource "local_file" "secondary_region_config" {
  content  = "Secondary Region Deployment Config: ${var.secondary_region}"
  filename = "${path.module}/generated_regions/secondary_us_west_2.txt"
}

# ------------------------------------------------------------------------------
# 3. Aliased Provider (Tertiary Region: eu-central-1)
# ------------------------------------------------------------------------------
# Explicitly uses `provider = aws.eu_central_1`
resource "aws_s3_bucket" "eu_bucket" {
  provider = aws.eu_central_1

  bucket = "eu-app-bucket-eu-central-1-${random_pet.bucket_suffix.id}"

  tags = {
    Name        = "EU Compliance Storage"
    Region      = "eu-central-1"
    Environment = var.environment
  }
}
