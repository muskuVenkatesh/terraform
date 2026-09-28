# ==============================================================================
# Terraform Meta-Argument: `count`
# Hands-On Practice & Implementation
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. Basic Count: Creating Multiple Local Files using `count.index`
# ------------------------------------------------------------------------------
resource "local_file" "server_logs" {
  count    = var.server_count
  content  = "Server #${count.index + 1} log initialized in environment: ${var.environment}"
  filename = "${path.module}/generated_logs/server_${count.index + 1}.log"
}

# ------------------------------------------------------------------------------
# 2. Advanced Count: Iterating Over a List of Names using length() & element()
# ------------------------------------------------------------------------------
resource "local_file" "user_configs" {
  count    = length(var.iam_user_names)
  content  = "User Configuration Profile for: ${var.iam_user_names[count.index]}"
  filename = "${path.module}/generated_users/${var.iam_user_names[count.index]}.txt"
}

# ------------------------------------------------------------------------------
# 3. Conditional Creation: Using `count` as a Switch (Ternary Operator)
# ------------------------------------------------------------------------------
# If var.enable_bastion_host is true  -> count = 1 (Resource Created)
# If var.enable_bastion_host is false -> count = 0 (Resource Skipped)
resource "local_file" "bastion_config" {
  count    = var.enable_bastion_host ? 1 : 0
  content  = "Bastion host configuration enabled for environment: ${var.environment}"
  filename = "${path.module}/generated_configs/bastion_host.txt"
}

# ------------------------------------------------------------------------------
# 4. AWS IAM Users Example using count
# ------------------------------------------------------------------------------
resource "aws_iam_user" "team_members" {
  count = length(var.iam_user_names)
  name  = var.iam_user_names[count.index]

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    UserIndex   = count.index
  }
}

# ------------------------------------------------------------------------------
# 5. AWS EC2 Instances Example using count and count.index
# ------------------------------------------------------------------------------
resource "aws_instance" "web_servers" {
  count         = var.server_count
  ami           = "ami-0fef201115eefe936"
  instance_type = "t3.micro"

  tags = {
    Name        = "${var.environment}-web-server-${count.index + 1}"
    Environment = var.environment
    Index       = count.index
  }
}
