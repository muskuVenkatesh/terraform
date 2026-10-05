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
provider "local" {

}
resource "local_file" "environment" {
    filename = "${path.module}/${terraform.workspace}.txt"
    content = <<-EOT
        Environment: ${terraform.workspace}
        Application: Terraform Workspace Practice
    EOT
}

# data "aws_ami" "amazon_linux" {
#   most_recent = true

#   owners = ["amazon"]

#   filter {
#     name   = "name"
#     values = ["al2023-ami-*-x86_64"]
#   }

#   filter {
#     name   = "state"
#     values = ["available"]
#   }
# }

resource "aws_instance" "web" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type

  subnet_id = data.aws_subnets.default.ids[0]

  tags = {
    Name        = "${terraform.workspace}-web-server"
    Environment = terraform.workspace
  }
}