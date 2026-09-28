# ==============================================================================
# Outputs for Resources Created with `depends_on`
# ==============================================================================

output "db_init_filename" {
  description = "Path to database initialization step 1 file"
  value       = local_file.db_init.filename
}

output "app_config_filename" {
  description = "Path to app config step 2 file (created after db_init)"
  value       = local_file.app_config.filename
}

output "s3_bucket_name" {
  description = "Name of the log S3 bucket"
  value       = aws_s3_bucket.app_logs.bucket
}

output "iam_role_arn" {
  description = "ARN of the application IAM role"
  value       = aws_iam_role.app_role.arn
}

output "web_app_instance_id" {
  description = "ID of the web app server created after IAM policy attachment"
  value       = aws_instance.web_app.id
}
