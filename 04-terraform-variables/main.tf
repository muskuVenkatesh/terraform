# ==============================================================================
# LOCAL VALUES (Locals)
# Derived from Input Variables - NOT configurable directly by external users
# ==============================================================================
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  # Select instance type based on environment map variable
  selected_instance_type = lookup(var.instance_types, var.environment, "t3.micro")

  # Merge standard common tags with dynamic resource tags
  merged_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
    }
  )
}

# ==============================================================================
# OFFLINE TEST RESOURCES (Random & Local Providers)
# Works without active AWS cloud credentials for instant local testing
# ==============================================================================

resource "random_pet" "bucket_suffix" {
  length    = 2
  separator = "-"
}

resource "local_file" "config_summary" {
  filename = "${path.module}/generated_config.txt"
  content  = <<-EOT
    =====================================================
    TERRAFORM VARIABLE PRACTICE CONFIGURATION SUMMARY
    =====================================================
    Project Name       : ${var.project_name}
    Environment        : ${var.environment}
    AWS Region         : ${var.aws_region}
    Instance Type      : ${local.selected_instance_type}
    Instance Count     : ${var.instance_count}
    Monitoring Enabled : ${var.enable_monitoring}
    Availability Zones : ${join(", ", var.availability_zones)}
    Allowed Ports      : ${join(", ", [for p in var.allowed_ports : tostring(p)])}

    Database Name      : ${var.database_config.name}
    Database Port      : ${var.database_config.port}
    DB Multi-AZ        : ${var.database_config.multi_az}
    DB Retention Days  : ${var.database_config.backup_retention}
    =====================================================
  EOT
}

# ==============================================================================
# AWS EXAMPLE RESOURCES (Demonstrates AWS Infrastructure Patterns)
# ==============================================================================

resource "aws_s3_bucket" "app_bucket" {
  bucket = "${local.name_prefix}-${random_pet.bucket_suffix.id}"

  tags = local.merged_tags
}

resource "aws_security_group" "web_sg" {
  name        = "${local.name_prefix}-web-sg"
  description = "Security Group configured via Terraform variables"

  dynamic "ingress" {
    for_each = var.allowed_ports
    content {
      description = "Allowed port from set variable"
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  tags = local.merged_tags
}

resource "aws_instance" "web_server" {
  count         = var.instance_count
  ami           = "ami-0c55b159cbfafe1f0" # Example Amazon Linux 2 AMI
  instance_type = local.selected_instance_type

  tags = merge(
    local.merged_tags,
    {
      Name = "${local.name_prefix}-server-${count.index + 1}"
    }
  )
}
