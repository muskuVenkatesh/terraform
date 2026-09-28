# ==============================================================================
# Terraform Meta-Argument: `lifecycle`
# Hands-On Practice & Implementation
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. `create_before_destroy`: Zero-Downtime Replacement
# ------------------------------------------------------------------------------
# Terraform normally destroys the existing resource before creating its replacement.
# `create_before_destroy = true` forces Terraform to build the new resource FIRST,
# ensuring zero service interruption before destroying the old one.
resource "local_file" "zero_downtime_config" {
  content  = "Zero-downtime configuration version: 1.0 - Env: ${var.environment}"
  filename = "${path.module}/generated_configs/app_config.txt"

  lifecycle {
    create_before_destroy = true
  }
}

# ------------------------------------------------------------------------------
# 2. `prevent_destroy`: Safeguard Critical Infrastructure
# ------------------------------------------------------------------------------
# Prevents Terraform from destroying critical resources (e.g., Production DBs, S3 Buckets).
# Terraform will raise an explicit error during `terraform destroy` or plan if replacement is needed.
resource "local_file" "protected_database_dump" {
  content  = "CRITICAL DATABASE BACKUP - DO NOT DESTROY"
  filename = "${path.module}/generated_configs/database_backup.txt"

  lifecycle {
    prevent_destroy = true
  }
}

# ------------------------------------------------------------------------------
# 3. `ignore_changes`: Drift Ignore / Auto-Scaled Attributes
# ------------------------------------------------------------------------------
# Ignores external changes to specified resource attributes (e.g., tags updated by CI/CD, auto-scaled instance counts).
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  tags = {
    Name           = var.server_name
    Environment    = var.environment
    LastDeployedBy = "CI-CD-Runner"
  }

  lifecycle {
    # Ignore drift on LastDeployedBy tag and user_data updates
    ignore_changes = [
      tags["LastDeployedBy"],
      user_data
    ]
  }
}

# ------------------------------------------------------------------------------
# 4. `replace_triggered_by`: Force Replacement on Dependency Updates
# ------------------------------------------------------------------------------
# Forces replacement of this resource whenever the referenced dependency changes.
resource "local_file" "app_version" {
  content  = "v1.0.4"
  filename = "${path.module}/generated_configs/version.txt"
}

resource "local_file" "deployed_manifest" {
  content  = "Deployed manifest for version: ${local_file.app_version.content}"
  filename = "${path.module}/generated_configs/manifest.txt"

  lifecycle {
    replace_triggered_by = [
      local_file.app_version.content
    ]
  }
}
