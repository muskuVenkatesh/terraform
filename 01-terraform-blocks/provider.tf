# ==============================================================================
# BLOCK TYPE 1: terraform block
# Purpose: Configures Terraform CLI settings, backend storage, and required provider plugins.
# ==============================================================================
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
  }
}

# ==============================================================================
# BLOCK TYPE 2: provider block
# Purpose: Configures the connection settings for cloud platforms or local plugins.
# ==============================================================================
provider "aws" {
  region = var.aws_region
}