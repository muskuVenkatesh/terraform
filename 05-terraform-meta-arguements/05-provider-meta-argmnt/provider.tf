terraform {
  required_version = ">= 1.0"

  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# 1. Default AWS Provider (Primary Region: US East 1)
provider "aws" {
  region = var.primary_region
}

# 2. Aliased AWS Provider (Secondary Region: US West 2)
provider "aws" {
  alias  = "us_west_2"
  region = var.secondary_region
}

# 3. Aliased AWS Provider (Tertiary Region: EU Central 1)
provider "aws" {
  alias  = "eu_central_1"
  region = "eu-central-1"
}
