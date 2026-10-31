terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_iam_user" "users" {
  for_each = var.user_names
  name     = each.value

  tags = {
    Name = each.value
  }
}



resource "aws_instance" "web-server" {
  for_each      = var.servers
  ami           = each.value.ami_id
  instance_type = each.value.instance_type

  tags = {
    Name        = each.key
    Environment = each.value.environment
  }
  lifecycle {
    create_before_destroy = true
  }

  provisioner "local-exec" {
    command = "echo 'Provisioning ${each.key} server in ${each.value.environment} environment with instance type ${each.value.instance_type}'"
  }


}



