# ==============================================================================
# Outputs for Resources Created with `provider` Meta-Argument
# ==============================================================================

output "primary_bucket_name" {
  description = "Name of bucket in primary region (us-east-1)"
  value       = aws_s3_bucket.primary_bucket.bucket
}

output "secondary_bucket_name" {
  description = "Name of bucket in secondary region (us-west-2 via provider = aws.us_west_2)"
  value       = aws_s3_bucket.secondary_bucket.bucket
}

output "eu_bucket_name" {
  description = "Name of bucket in EU region (eu-central-1 via provider = aws.eu_central_1)"
  value       = aws_s3_bucket.eu_bucket.bucket
}

output "primary_config_file" {
  description = "Path to primary region config file"
  value       = local_file.primary_region_config.filename
}

output "secondary_config_file" {
  description = "Path to secondary region config file"
  value       = local_file.secondary_region_config.filename
}
