variable "aws_region" {
  type        = string
  description = "AWS Region for deployment"
  default     = "us-east-1"
}

variable "environment" {
  type        = string
  description = "Deployment environment name"
  default     = "dev"
}

# 1. Set of Strings (Set iteration)
variable "user_names" {
  type        = set(string)
  description = "Set of IAM / Local user names to iterate over using for_each"
  default = [
    "alice",
    "bob",
    "charlie"
  ]
}

# 2. Map of Strings (Map iteration)
variable "subnet_cidrs" {
  type        = map(string)
  description = "Map of subnet names to CIDR blocks"
  default = {
    public_subnet_1  = "10.0.1.0/24"
    public_subnet_2  = "10.0.2.0/24"
    private_subnet_1 = "10.0.10.0/24"
    private_subnet_2 = "10.0.20.0/24"
  }
}

# 3. Map of Objects (Complex map iteration)
variable "environment_servers" {
  type = map(object({
    instance_type = string
    environment   = string
    role          = string
  }))
  description = "Map of server configurations for for_each iteration"
  default = {
    web = {
      instance_type = "t3.micro"
      environment   = "dev"
      role          = "frontend"
    }
    api = {
      instance_type = "t3.small"
      environment   = "dev"
      role          = "backend"
    }
    db = {
      instance_type = "t3.medium"
      environment   = "prod"
      role          = "database"
    }
  }
}

# 4. List of Objects (List to Map transformation)
variable "s3_bucket_configs" {
  type = list(object({
    name    = string
    purpose = string
  }))
  description = "List of bucket objects converted into a map for for_each"
  default = [
    { name = "app-logs-storage", purpose = "Application Logs Storage" },
    { name = "user-media-uploads", purpose = "User Profile Media" },
    { name = "system-backups", purpose = "Disaster Recovery Backups" }
  ]
}