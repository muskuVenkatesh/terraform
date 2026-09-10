# Terraform Notes & AWS EC2 Implementation

## Table of Contents

1. [What is Terraform?](#what-is-terraform)
2. [Why Use Terraform?](#why-use-terraform)
3. [Infrastructure as Code](#infrastructure-as-code)
4. [Terraform Workflow](#terraform-workflow)
5. [Terraform Building Blocks](#terraform-building-blocks)
6. [Terraform State](#terraform-state)
7. [terraform.tfstate.backup](#terraformtfstatebackup)
8. [Terraform Project Structure](#terraform-project-structure)
9. [AWS Provider](#aws-provider)
10. [EC2 Implementation](#ec2-implementation)
11. [Security Group Configuration](#security-group-configuration)
12. [EC2 Configuration](#ec2-configuration)
13. [User Data](#user-data)
14. [Terraform Commands](#terraform-commands)
15. [Terraform Destroy](#terraform-destroy)
16. [Best Practices](#best-practices)
17. [Next Steps](#next-steps)

---

# What is Terraform?

Terraform is an **Infrastructure as Code (IaC)** tool developed by HashiCorp.

It allows us to define and manage infrastructure using configuration files instead of manually creating resources through a cloud provider's console.

Terraform can be used with:

* AWS
* Azure
* Google Cloud
* Kubernetes
* GitHub
* Cloudflare
* And many other platforms

For AWS, Terraform can create and manage resources such as:

* EC2
* S3
* VPC
* Subnets
* Security Groups
* RDS
* IAM
* Load Balancers
* Auto Scaling Groups
* Route 53

---

# Why Use Terraform?

Without Terraform, infrastructure can be created manually:

```text
AWS Console
    ↓
Create VPC
    ↓
Create Subnet
    ↓
Create Security Group
    ↓
Create EC2
    ↓
Configure EC2
```

With Terraform:

```text
Terraform Configuration
        ↓
terraform plan
        ↓
terraform apply
        ↓
AWS Infrastructure
```

### Main advantages

* Infrastructure can be automated.
* Configuration can be stored in Git.
* Infrastructure can be reproduced.
* Changes can be reviewed before applying.
* Resources can be managed consistently.
* Manual configuration is reduced.
* Infrastructure can be destroyed and recreated when required.

---

# Infrastructure as Code

Infrastructure as Code means managing infrastructure through configuration files.

Instead of manually creating an EC2 instance from the AWS Console:

```text
AWS Console
    ↓
Launch EC2
    ↓
Select AMI
    ↓
Select Instance Type
    ↓
Configure Network
    ↓
Configure Security Group
```

We define the infrastructure in Terraform:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

Terraform then creates the EC2 instance.

---

# Terraform Workflow

The standard Terraform workflow is:

```text
Write Terraform Configuration
            ↓
      terraform init
            ↓
      terraform fmt
            ↓
    terraform validate
            ↓
       terraform plan
            ↓
      Review Changes
            ↓
      terraform apply
            ↓
      AWS Infrastructure
```

When infrastructure is no longer required:

```text
terraform destroy
        ↓
AWS Resources Deleted
```

---

# Terraform Building Blocks

Terraform has several important blocks.

## 1. terraform block

The `terraform` block defines Terraform settings such as the required Terraform version and providers.

Example:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}
```

---

## 2. provider block

The provider tells Terraform which platform it should communicate with.

Example:

```hcl
provider "aws" {
  region = "ap-south-2"
}
```

For this project, AWS is the provider.

---

## 3. resource block

The `resource` block defines infrastructure that Terraform should create or manage.

Example:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

Structure:

```text
resource "RESOURCE_TYPE" "RESOURCE_NAME" {
    configuration
}
```

In this example:

```text
aws_instance → Resource type
web          → Resource name
```

---

## 4. variable block

Variables allow us to make Terraform configurations reusable.

Example:

```hcl
variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
```

Use it with:

```hcl
instance_type = var.instance_type
```

---

## 5. output block

Outputs display useful information after Terraform creates infrastructure.

Example:

```hcl
output "instance_id" {
  value = aws_instance.web.id
}
```

Another example:

```hcl
output "public_ip" {
  value = aws_instance.web.public_ip
}
```

---

## 6. data block

A `data` block retrieves information about existing infrastructure.

Example:

```hcl
data "aws_vpc" "existing" {
  id = "vpc-xxxxxxxx"
}
```

It does not create the VPC.

It reads information about an existing resource.

---

## 7. locals block

The `locals` block defines reusable internal values.

Example:

```hcl
locals {
  project_name = "terraform-project"
  environment  = "dev"
}
```

Use:

```hcl
tags = {
  Project     = local.project_name
  Environment = local.environment
}
```

---

## 8. module block

Modules allow Terraform configurations to be reused.

Example:

```hcl
module "vpc" {
  source = "./modules/vpc"
}
```

Modules are useful for larger projects.

---

## 9. moved block

The `moved` block is used when changing the Terraform address of a resource without unnecessarily destroying and recreating it.

Example:

```hcl
moved {
  from = aws_instance.web
  to   = aws_instance.application
}
```

---

# Terraform State

Terraform uses a state file to keep track of the infrastructure it manages.

The default state file is:

```text
terraform.tfstate
```

Think of the state file as Terraform's **memory**.

```text
Terraform Configuration
        ↓
     main.tf
        ↓
Terraform State
        ↓
terraform.tfstate
        ↓
AWS Infrastructure
```

The state can contain information such as:

* Resource IDs
* Resource attributes
* Instance IDs
* IP addresses
* ARNs
* Provider information
* Relationships between resources

---

# terraform.tfstate

`terraform.tfstate` represents the **current state known by Terraform**.

For example:

```text
terraform.tfstate
        ↓
EC2 Instance
        ↓
Instance ID
        ↓
Private IP
        ↓
Public IP
        ↓
Security Group
```

Terraform uses this information when running:

```bash
terraform plan
terraform apply
terraform destroy
```

---

# terraform.tfstate.backup

Terraform may also maintain:

```text
terraform.tfstate.backup
```

This file contains a previous version of the Terraform state.

Conceptually:

```text
terraform.tfstate
        ↓
CURRENT STATE

terraform.tfstate.backup
        ↓
PREVIOUS STATE
```

It provides a basic recovery point for state changes.

Do not manually edit the state files unless you specifically understand Terraform state management.

---

# State File Security

Do not normally commit Terraform state files to GitHub.

Add the following to `.gitignore`:

```gitignore
terraform.tfstate
terraform.tfstate.*
.terraform/
*.tfvars
*.tfvars.json
```

State files can contain sensitive information depending on the resources being managed.

For production and team environments, remote state should normally be used.

---

# Terraform Project Structure

For the EC2 project, a clean structure is:

```text
terraform-ec2/
├── provider.tf
├── variables.tf
├── security-group.tf
├── ec2.tf
├── outputs.tf
├── terraform.tfvars
├── .gitignore
└── README.md
```

Terraform automatically creates:

```text
.terraform/
terraform.tfstate
terraform.tfstate.backup
.terraform.lock.hcl
```

after initialization and infrastructure operations.

---

# AWS Provider

The AWS provider allows Terraform to communicate with AWS.

Example:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

---

# EC2 Implementation

## Objective

Create an Amazon EC2 instance using Terraform.

The implementation includes:

* AWS provider
* Variables
* Security Group
* EC2 instance
* SSH key pair
* Public IP
* Apache web server
* EBS root volume
* EBS encryption
* Terraform outputs

---

# Step 1 – Create Project Directory

Create a separate directory for the EC2 project:

```bash
mkdir terraform-ec2
cd terraform-ec2
```

---

# Step 2 – Create Provider Configuration

Create:

```text
provider.tf
```

Configuration:

```hcl
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}
```

---

# Step 3 – Create Variables

Create:

```text
variables.tf
```

Configuration:

```hcl
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "ap-south-2"
}

variable "ami_id" {
  description = "AMI ID for the EC2 instance"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "instance_name" {
  description = "Name tag for EC2"
  type        = string
  default     = "terraform-ec2"
}

variable "key_name" {
  description = "Existing EC2 key pair name"
  type        = string
}
```

---

# Step 4 – Configure terraform.tfvars

Create:

```text
terraform.tfvars
```

Example:

```hcl
aws_region    = "ap-south-2"
ami_id        = "YOUR_AMI_ID"
instance_type = "t3.micro"
instance_name = "terraform-ec2"
key_name      = "YOUR_KEY_PAIR_NAME"
```

Replace:

```text
YOUR_AMI_ID
```

with a valid AMI ID from the same AWS region.

Replace:

```text
YOUR_KEY_PAIR_NAME
```

with an existing EC2 key pair.

Do not commit `terraform.tfvars` if it contains secrets.

---

# Step 5 – Create Security Group

Create:

```text
security-group.tf
```

Configuration:

```hcl
resource "aws_security_group" "ec2_sg" {
  name        = "terraform-ec2-sg"
  description = "Security group for Terraform EC2"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["YOUR_PUBLIC_IP/32"]
  }

  ingress {
    description = "HTTP"
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

  tags = {
    Name = "terraform-ec2-sg"
  }
}
```

For SSH, it is better to restrict access to your own public IP:

```text
YOUR_PUBLIC_IP/32
```

Instead of:

```text
0.0.0.0/0
```

You can check your public IP using:

```bash
curl https://checkip.amazonaws.com
```

---

# Step 6 – Create EC2 Instance

Create:

```text
ec2.tf
```

Configuration:

```hcl
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
  key_name      = var.key_name

  vpc_security_group_ids = [
    aws_security_group.ec2_sg.id
  ]

  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash

              dnf update -y
              dnf install -y httpd

              systemctl enable httpd
              systemctl start httpd

              echo "<h1>Hello from Terraform EC2</h1>" > /var/www/html/index.html
              EOF

  root_block_device {
    volume_size = 8
    volume_type = "gp3"
    encrypted   = true
  }

  tags = {
    Name = var.instance_name
  }
}
```

---

# Step 7 – User Data

The `user_data` section runs commands when the EC2 instance starts for the first time.

In this example:

```bash
dnf update -y
dnf install -y httpd
systemctl enable httpd
systemctl start httpd
```

The commands:

1. Update the operating system.
2. Install Apache HTTP Server.
3. Enable Apache.
4. Start Apache.
5. Create a simple web page.

The page contains:

```html
<h1>Hello from Terraform EC2</h1>
```

---

# Step 8 – Configure Outputs

Create:

```text
outputs.tf
```

Configuration:

```hcl
output "instance_id" {
  description = "EC2 instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "EC2 public IP"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "EC2 public DNS"
  value       = aws_instance.web.public_dns
}
```

---

# Step 9 – Initialize Terraform

Run:

```bash
terraform init
```

This downloads the required provider and initializes the Terraform working directory.

---

# Step 10 – Format Configuration

Run:

```bash
terraform fmt
```

This formats Terraform configuration files consistently.

---

# Step 11 – Validate Configuration

Run:

```bash
terraform validate
```

Expected result:

```text
Success! The configuration is valid.
```

---

# Step 12 – Create Terraform Plan

Run:

```bash
terraform plan
```

Terraform will calculate the changes without creating infrastructure.

Example:

```text
Plan: 2 to add, 0 to change, 0 to destroy.
```

Resources:

```text
aws_security_group.ec2_sg
aws_instance.web
```

Always review the plan before applying it.

---

# Step 13 – Apply Configuration

Run:

```bash
terraform apply
```

Terraform will display the planned changes and ask for confirmation.

Enter:

```text
yes
```

Terraform then creates the AWS infrastructure.

---

# Step 14 – Check Outputs

Run:

```bash
terraform output
```

Example:

```text
instance_id = "i-xxxxxxxxxxxxxxxxx"
public_ip   = "xx.xx.xx.xx"
public_dns  = "ec2-xx-xx-xx-xx..."
```

Open the public IP in a browser:

```text
http://YOUR_PUBLIC_IP
```

Expected result:

```text
Hello from Terraform EC2
```

---

# Terraform Destroy

When the EC2 instance is no longer required, Terraform can remove the infrastructure.

First review the destroy plan:

```bash
terraform plan -destroy
```

If everything looks correct:

```bash
terraform destroy
```

Terraform asks for confirmation.

Enter:

```text
yes
```

Terraform then deletes the resources that it manages.

For example:

```text
Terraform
    ↓
terraform.tfstate
    ↓
Find managed resources
    ↓
EC2 Instance
Security Group
    ↓
Delete from AWS
```

---

# What Terraform Destroy Does NOT Delete

Running:

```bash
terraform destroy
```

does not delete your Terraform project files.

These remain:

```text
provider.tf
variables.tf
security-group.tf
ec2.tf
outputs.tf
terraform.tfvars
README.md
```

Terraform removes the AWS infrastructure, not your configuration files.

You can recreate the infrastructure later using:

```bash
terraform apply
```

---

# Important Terraform Commands

## Initialize

```bash
terraform init
```

Initializes the Terraform project.

---

## Format

```bash
terraform fmt
```

Formats Terraform files.

---

## Validate

```bash
terraform validate
```

Checks Terraform configuration syntax and configuration validity.

---

## Plan

```bash
terraform plan
```

Shows what Terraform intends to change.

---

## Apply

```bash
terraform apply
```

Creates or updates infrastructure.

---

## Destroy

```bash
terraform destroy
```

Deletes Terraform-managed infrastructure.

---

## Show State

```bash
terraform show
```

Displays the current Terraform state.

---

## List Resources

```bash
terraform state list
```

Displays resources currently tracked by Terraform.

---

## Inspect a Resource

```bash
terraform state show aws_instance.web
```

Displays information about a specific resource.

---

## Display Outputs

```bash
terraform output
```

Displays Terraform outputs.

---

# Terraform State Lifecycle

A simplified Terraform lifecycle looks like this:

```text
main.tf
   ↓
terraform plan
   ↓
terraform apply
   ↓
AWS Resource Created
   ↓
terraform.tfstate Updated
```

When infrastructure changes:

```text
Modify .tf file
      ↓
terraform plan
      ↓
Compare desired state
      ↓
Compare current state
      ↓
terraform apply
      ↓
AWS updated
      ↓
terraform.tfstate updated
```

When destroying:

```text
terraform destroy
       ↓
Read terraform.tfstate
       ↓
Identify managed resources
       ↓
Delete AWS resources
       ↓
Update state
```

---

# Best Practices

## 1. Use Git

Store Terraform configuration in Git.

```bash
git init
```

---

## 2. Do Not Commit State Files

Add:

```gitignore
terraform.tfstate
terraform.tfstate.*
```

to `.gitignore`.

---

## 3. Do Not Commit Secrets

Never commit:

* AWS secret keys
* Passwords
* API tokens
* Private keys
* Database passwords

---

## 4. Use Variables

Instead of:

```hcl
instance_type = "t3.micro"
```

use:

```hcl
instance_type = var.instance_type
```

This makes the configuration reusable.

---

## 5. Always Run Plan Before Apply

Recommended workflow:

```bash
terraform fmt
terraform validate
terraform plan
terraform apply
```

Review the plan before applying.

---

## 6. Use Remote State for Team Projects

For larger projects, use a remote backend instead of relying on local:

```text
terraform.tfstate
```

A common AWS architecture is:

```text
Terraform
    ↓
S3 Remote State
```

Remote state is especially useful for team environments and CI/CD.

---

## 7. Use Least Privilege

Avoid using `AdministratorAccess` for production Terraform deployments.

Create permissions appropriate for the resources Terraform needs to manage.

For learning environments, broader permissions may be used temporarily.

---

# Experienced Terraform Workflow

A professional Terraform workflow generally looks like:

```text
Developer
    ↓
Terraform Code
    ↓
Git
    ↓
Code Review
    ↓
terraform fmt
    ↓
terraform validate
    ↓
terraform plan
    ↓
Review Plan
    ↓
terraform apply
    ↓
AWS Infrastructure
```

For larger teams:

```text
Developer
    ↓
Git Repository
    ↓
CI/CD Pipeline
    ↓
Terraform Plan
    ↓
Approval
    ↓
Terraform Apply
    ↓
AWS
```

---

# Current EC2 Architecture

The current learning implementation is:

```text
                  Internet
                     |
                     |
                Public IP
                     |
              +-------------+
              |    EC2      |
              | Web Server  |
              +-------------+
                     |
              Security Group
               /          \
             SSH          HTTP
              22            80
```

The EC2 instance contains:

```text
EC2
├── Amazon Linux
├── Apache HTTP Server
├── Root EBS Volume
├── Public IP
└── Security Group
```

---

# Current Learning Progress

The Terraform learning path covered so far:

* [x] What is Terraform?
* [x] Infrastructure as Code
* [x] Terraform workflow
* [x] Terraform blocks
* [x] Provider block
* [x] Resource block
* [x] Variable block
* [x] Output block
* [x] Data block
* [x] Locals block
* [x] Module block
* [x] Terraform state
* [x] `terraform.tfstate`
* [x] `terraform.tfstate.backup`
* [x] Terraform commands
* [x] EC2 configuration
* [x] Security Group
* [x] User Data
* [x] EBS configuration
* [x] Terraform apply
* [x] Terraform destroy

---

# Next Steps

After completing the basic EC2 implementation, the recommended learning sequence is:

```text
1. EC2
   ↓
2. VPC
   ↓
3. Subnets
   ↓
4. Internet Gateway
   ↓
5. Route Tables
   ↓
6. Security Groups
   ↓
7. NAT Gateway
   ↓
8. RDS
   ↓
9. Load Balancer
   ↓
10. Auto Scaling
   ↓
11. Modules
   ↓
12. Data Sources
   ↓
13. Remote State
   ↓
14. State Locking / Concurrency
   ↓
15. Terraform with CI/CD
```

The ultimate goal is to manage a complete AWS architecture using Terraform instead of manually creating each resource through the AWS Console.

---

# Summary

Terraform allows infrastructure to be managed as code.

The most important concepts to remember are:

```text
terraform block
      ↓
provider block
      ↓
variables
      ↓
resources
      ↓
terraform plan
      ↓
terraform apply
      ↓
terraform.tfstate
      ↓
AWS Infrastructure
```

And when the infrastructure is no longer required:

```text
terraform destroy
      ↓
AWS Infrastructure Removed
```

**Key definition:**

> Terraform is an Infrastructure as Code tool that allows us to define, provision, and manage infrastructure using declarative configuration files.
