output "project_info" {
  description = "Combined project environment information"
  value = {
    project     = var.project_name
    environment = var.environment
    region      = var.aws_region
  }
}

output "selected_instance_type" {
  description = "EC2 instance type calculated dynamically from environment"
  value       = local.selected_instance_type
}

output "generated_config_file" {
  description = "Path to the generated configuration summary file"
  value       = local_file.config_summary.filename
}

output "database_details" {
  description = "Non-sensitive database configuration summary"
  value = {
    db_name  = var.database_config.name
    port     = var.database_config.port
    multi_az = var.database_config.multi_az
  }
}

output "db_password_output" {
  description = "Database administrator password (Marked as sensitive)"
  value       = var.db_password
  sensitive   = true
}
