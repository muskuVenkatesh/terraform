# ==============================================================================
# BLOCK TYPE 8: output block
# Purpose: Exports values from Terraform infrastructure after terraform apply.
# ==============================================================================

output "aws_account_id" {
  description = "Current AWS Account ID fetched from data block"
  value       = data.aws_caller_identity.current.account_id
}

output "latest_ami_id" {
  description = "Dynamically fetched Amazon Linux 2 AMI ID from data block"
  value       = data.aws_ami.latest_amazon_linux.id
}

output "web_server_id" {
  description = "ID of created EC2 instance resource"
  value       = aws_instance.web_server.id
}

output "security_group_id" {
  description = "ID of created Security Group resource"
  value       = aws_security_group.web_sg.id
}

output "summary_file_path" {
  description = "Path to the generated local configuration summary file"
  value       = local_file.summary.filename
}