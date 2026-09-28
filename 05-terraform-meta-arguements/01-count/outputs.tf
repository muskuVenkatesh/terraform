# ==============================================================================
# Outputs for Resources Created with `count`
# ==============================================================================

# 1. Output all created local file paths using Splat Operator [*]
output "server_log_files" {
  description = "List of generated log file paths"
  value       = local_file.server_logs[*].filename
}

# 2. Output user config filenames using `for` expression
output "user_config_files" {
  description = "Map of user names to generated configuration files"
  value = {
    for idx, file in local_file.user_configs :
    var.iam_user_names[idx] => file.filename
  }
}

# 3. Conditional Output: Safely reference element [0] when count is 0 or 1
output "bastion_config_file" {
  description = "Path to bastion configuration file (if created)"
  value       = length(local_file.bastion_config) > 0 ? local_file.bastion_config[0].filename : "Bastion Host Not Created"
}

# 4. Output list of IAM User ARNs using Splat Operator [*]
output "iam_user_arns" {
  description = "List of IAM User ARNs created using count"
  value       = aws_iam_user.team_members[*].arn
}

# 5. Output specific instance ID by Index lookup [0]
output "primary_web_server_id" {
  description = "ID of the first web server instance"
  value       = length(aws_instance.web_servers) > 0 ? aws_instance.web_servers[0].id : null
}

# 6. Output all Web Server IDs as a List
output "all_web_server_ids" {
  description = "List of all web server instance IDs"
  value       = aws_instance.web_servers[*].id
}
