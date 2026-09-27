# ==============================================================================
# BLOCK TYPE 6: resource block
# Purpose: Defines infrastructure components to manage (e.g. AWS EC2, S3, SG).
# ==============================================================================

# Resource Example 1: Security Group
resource "aws_security_group" "web_sg" {
  name        = "${local.name_prefix}-sg"
  description = "Security group for web server"

  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.common_tags
}

# Resource Example 2: EC2 Instance using data source AMI and local tags
resource "aws_instance" "web_server" {
  ami           = data.aws_ami.latest_amazon_linux.id
  instance_type = var.instance_type

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = merge(
    local.common_tags,
    {
      Name = "${local.name_prefix}-web"
    }
  )
}

# Resource Example 3: Local file resource (Works offline for instant practice testing!)
resource "local_file" "summary" {
  filename = "${path.module}/block_summary.txt"
  content  = <<-EOT
    =====================================================
    TERRAFORM BLOCKS PRACTICAL DEMONSTRATION
    =====================================================
    Project Name   : ${var.project_name}
    Environment    : ${var.environment}
    AWS Account ID : ${data.aws_caller_identity.current.account_id}
    Fetched AMI ID : ${data.aws_ami.latest_amazon_linux.id}
    Instance Type  : ${var.instance_type}
    EC2 Name Tag   : ${local.name_prefix}-web
    =====================================================
  EOT
}

# ==============================================================================
# BLOCK TYPE 7: module block
# Purpose: Reuses pre-packaged groups of Terraform resources from local folders or registry.
# ==============================================================================

# Example demonstrating child module invocation pattern:
# module "s3_bucket" {
#   source = "terraform-aws-modules/s3-bucket/aws"
#   bucket = "${local.name_prefix}-bucket"
#   tags   = local.common_tags
# }
