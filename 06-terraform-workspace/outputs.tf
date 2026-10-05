output "workspace" {
  description = "Current Terraform workspace"
  value       = terraform.workspace
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "instance_type" {
  description = "EC2 instance type"
  value       = aws_instance.web.instance_type
}

output "instance_name" {
  description = "EC2 instance name"
  value       = "${terraform.workspace}-web-server"
}

output "private_ip" {
  description = "Private IP address"
  value       = aws_instance.web.private_ip
}