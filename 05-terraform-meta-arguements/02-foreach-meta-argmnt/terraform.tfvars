aws_region  = "us-east-1"
environment = "dev"

user_names = [
  "alice",
  "bob",
  "charlie"
]

subnet_cidrs = {
  public_subnet_1  = "10.0.1.0/24"
  public_subnet_2  = "10.0.2.0/24"
  private_subnet_1 = "10.0.10.0/24"
  private_subnet_2 = "10.0.20.0/24"
}

environment_servers = {
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

s3_bucket_configs = [
  { name = "app-logs-storage", purpose = "Application Logs Storage" },
  { name = "user-media-uploads", purpose = "User Profile Media" },
  { name = "system-backups", purpose = "Disaster Recovery Backups" }
]
