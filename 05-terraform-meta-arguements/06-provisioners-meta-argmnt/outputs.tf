# ==============================================================================
# Outputs for Provisioner Practice Module
# ==============================================================================

output "sample_app_file" {
  description = "Path to sample application file created locally"
  value       = local_file.sample_app.filename
}

output "null_resource_id" {
  description = "ID of null_resource used to trigger local script"
  value       = null_resource.inventory_builder.id
}

output "web_server_id" {
  description = "EC2 Instance ID provisioned with remote-exec & file provisioners"
  value       = aws_instance.web_server.id
}

output "web_server_public_ip" {
  description = "EC2 Instance Public IP"
  value       = aws_instance.web_server.public_ip
}
