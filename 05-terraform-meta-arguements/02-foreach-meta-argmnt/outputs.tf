# ==============================================================================
# Outputs for Resources Created with `for_each`
# ==============================================================================

# 1. Output map of filenames created from set of strings
output "user_profile_files" {
  description = "Map of user name to generated profile file path"
  value       = { for user, file in local_file.user_profiles : user => file.filename }
}

# 2. Output map of IAM User ARNs key-indexed by username
output "iam_user_arns" {
  description = "Map of usernames to IAM User ARNs"
  value       = { for user, iam in aws_iam_user.iam_users : user => iam.arn }
}

# 3. Output map of subnet CIDRs created from map iteration
output "subnet_file_paths" {
  description = "Map of subnet name to configuration file path"
  value       = { for subnet, file in local_file.subnet_configs : subnet => file.filename }
}

# 4. Output specific instance attributes from map of objects
output "server_instance_ids" {
  description = "Map of server keys to AWS EC2 instance IDs"
  value       = { for key, instance in aws_instance.web_cluster : key => instance.id }
}

# 5. Output transformed bucket configuration file paths
output "s3_bucket_file_paths" {
  description = "Map of bucket names to generated configuration files"
  value       = { for name, file in local_file.bucket_configs : name => file.filename }
}
