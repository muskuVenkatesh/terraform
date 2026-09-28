# ==============================================================================
# Terraform Meta-Argument: `depends_on`
# Hands-On Practice & Implementation
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Local File Practice: Explicit Sequential Execution with depends_on
# ------------------------------------------------------------------------------

# Step 1: Database Initialization File
resource "local_file" "db_init" {
  content  = "Database Schema initialized for app: ${var.app_name} in ${var.environment}"
  filename = "${path.module}/generated_step1_db_init.txt"
}

# Step 2: Application Config File (Explicitly dependent on Database initialization)
# Even though app_config doesn't reference any exported attribute of db_init,
# `depends_on` forces Terraform to wait until db_init is completely created.
resource "local_file" "app_config" {
  content  = "App Configuration connected to Database"
  filename = "${path.module}/generated_step2_app_config.txt"

  depends_on = [
    local_file.db_init
  ]
}

# ------------------------------------------------------------------------------
# 2. AWS Practice: IAM Role & S3 Bucket Policy with depends_on
# ------------------------------------------------------------------------------

# Create Random S3 Bucket Suffix
resource "random_pet" "bucket_name" {
  length    = 2
  separator = "-"
}

# AWS S3 Bucket for Logs
resource "aws_s3_bucket" "app_logs" {
  bucket = "${var.app_name}-logs-${random_pet.bucket_name.id}"
}

# AWS IAM Role for EC2 Application
resource "aws_iam_role" "app_role" {
  name = "${var.app_name}-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}

# AWS IAM Policy Attachment
resource "aws_iam_role_policy_attachment" "attach_s3_access" {
  role       = aws_iam_role.app_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# EC2 Instance requiring IAM Policy attachment to be completed first
# Explicit dependency ensures the IAM Policy is completely attached before EC2 launches!
resource "aws_instance" "web_app" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  tags = {
    Name        = "${var.app_name}-server"
    Environment = var.environment
  }

  depends_on = [
    aws_iam_role_policy_attachment.attach_s3_access,
    aws_s3_bucket.app_logs
  ]
}
