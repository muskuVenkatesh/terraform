# ==============================================================================
# BLOCK TYPE 4: locals block
# Purpose: Defines internal calculated values and reusable HCL expressions.
#          Locals are NOT configurable by users directly.
# ==============================================================================
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
