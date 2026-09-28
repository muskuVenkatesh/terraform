# ==============================================================================
# Outputs for Resources Created with `lifecycle`
# ==============================================================================

output "zero_downtime_config_file" {
  description = "File created using create_before_destroy = true"
  value       = local_file.zero_downtime_config.filename
}

output "protected_backup_file" {
  description = "File protected using prevent_destroy = true"
  value       = local_file.protected_database_dump.filename
}

output "web_server_id" {
  description = "EC2 server ID using ignore_changes lifecycle rule"
  value       = aws_instance.web_server.id
}

output "manifest_file" {
  description = "Manifest file with replace_triggered_by lifecycle rule"
  value       = local_file.deployed_manifest.filename
}
