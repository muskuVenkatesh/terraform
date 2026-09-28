# ==============================================================================
# Terraform Meta-Argument: `for_each`
# Hands-On Practice & Implementation
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. `for_each` over a Set of Strings (`set(string)`)
# ------------------------------------------------------------------------------
# When iterating over a set of strings, `each.key` and `each.value` are identical.
resource "local_file" "user_profiles" {
  for_each = var.user_names

  content  = "User Profile configuration for: ${each.key} in environment ${var.environment}"
  filename = "${path.module}/generated_users/${each.value}.txt"
}

# AWS IAM Users using set of strings
resource "aws_iam_user" "iam_users" {
  for_each = var.user_names

  name = "dev-${each.value}"

  tags = {
    Environment = var.environment
    ManagedBy   = "Terraform"
    UserName    = each.key
  }
}

# ------------------------------------------------------------------------------
# 2. `for_each` over a Map of Strings (`map(string)`)
# ------------------------------------------------------------------------------
# When iterating over a map, `each.key` is the map key and `each.value` is the map value.
resource "local_file" "subnet_configs" {
  for_each = var.subnet_cidrs

  content  = "Subnet Name: ${each.key} | CIDR Block: ${each.value}"
  filename = "${path.module}/generated_subnets/${each.key}.txt"
}

# ------------------------------------------------------------------------------
# 3. `for_each` over a Map of Objects (`map(object)`)
# ------------------------------------------------------------------------------
# Access individual object attributes using `each.value.attribute_name`
resource "local_file" "server_specs" {
  for_each = var.environment_servers

  content  = "Server Key: ${each.key}\nInstance Type: ${each.value.instance_type}\nEnvironment: ${each.value.environment}\nRole: ${each.value.role}"
  filename = "${path.module}/generated_servers/${each.key}_server.txt"
}

resource "aws_instance" "web_cluster" {
  for_each = var.environment_servers

  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = each.value.instance_type

  tags = {
    Name        = "${each.key}-server"
    Environment = each.value.environment
    Role        = each.value.role
  }
}

# ------------------------------------------------------------------------------
# 4. `for_each` with List-to-Map Transformation using a `for` expression
# ------------------------------------------------------------------------------
# `for_each` cannot iterate directly over a list of objects.
# We transform `var.s3_bucket_configs` (list) into a map using `{ for bucket in var.s3_bucket_configs : bucket.name => bucket }`
resource "local_file" "bucket_configs" {
  for_each = { for bucket in var.s3_bucket_configs : bucket.name => bucket }

  content  = "Bucket Name: ${each.key} | Purpose: ${each.value.purpose}"
  filename = "${path.module}/generated_buckets/${each.key}.txt"
}
