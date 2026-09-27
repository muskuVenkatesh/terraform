# ==============================================================================
# BLOCK TYPE 5: data block
# Purpose: Queries external data or existing cloud infrastructure into Terraform.
#          Data sources are read-only!
# ==============================================================================

# Example 1: Fetch latest Amazon Linux 2 AMI ID dynamically from AWS
data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

# Example 2: Fetch information about current AWS Account ID and region
data "aws_caller_identity" "current" {}
