# Terraform Multi-Region Deployment with Provider Aliases

This repository demonstrates how to manage AWS infrastructure across multiple geographical regions using a single Terraform configuration. By leveraging **Terraform Provider Aliases** (`alias`), you can define multiple instances of the same provider configured for different AWS regions and explicitly assign resources to specific regions.

---

## 📌 Table of Contents

- [Overview](#overview)
- [Key Concepts](#key-concepts)
  - [Default Provider vs. Aliased Provider](#default-provider-vs-aliased-provider)
  - [Resource-Level Provider Binding](#resource-level-provider-binding)
- [Project Structure](#project-structure)
- [Configuration Breakdown](#configuration-breakdown)
  - [Provider Configuration (`provider.tf`)](#provider-configuration-providertf)
  - [Resource Configuration (`resource.tf`)](#resource-configuration-resourcetf)
- [Getting Started](#getting-started)
  - [Prerequisites](#prerequisites)
  - [Execution Steps](#execution-steps)
- [Common Use Cases](#common-use-cases)
- [Best Practices](#best-practices)

---

## 🌍 Overview

In cloud infrastructure deployment, applications often require multi-region setups for:
- High Availability (HA) & Disaster Recovery (DR)
- Reduced latency for global users
- Compliance and data residency requirements
- Cross-region backups and replication

Terraform supports multi-region deployments seamlessly by allowing multiple `provider` blocks for the same provider type, distinguished using the `alias` argument.

---

## 🔑 Key Concepts

### Default Provider vs. Aliased Provider

- **Default Provider**: A provider configuration block *without* an `alias` attribute. Any resource that does not explicitly specify a `provider` meta-argument will use the default provider.
- **Aliased Provider**: A provider configuration block that includes an `alias` attribute (e.g., `alias = "us_east_1"`). This allows you to create additional instances of the provider with different parameters (such as `region`, `profile`, or `role_arn`).

### Resource-Level Provider Binding

Resources use the default provider unless explicitly assigned to an aliased provider using the `provider` meta-argument:

```hcl
resource "aws_s3_bucket" "example" {
  provider = aws.us_east_1 # Explicitly references the aliased provider
  bucket   = "my-multi-region-bucket"
}
```

---

## 📁 Project Structure

```text
terraform-multi-region/
├── provider.tf        # AWS provider declarations (default & aliased)
├── resource.tf        # S3 bucket definitions assigned to respective regions
└── Readme.md          # Project documentation
```

---

## 🛠 Configuration Breakdown

### Provider Configuration (`provider.tf`)

`provider.tf` configures the HashiCorp AWS provider requirements and defines two provider instances:
1. **Default Provider**: Targets region `ap-south-2` (Hyderabad, India).
2. **Aliased Provider (`aws.us_east_1`)**: Targets region `us-east-1` (N. Virginia, USA).

```hcl
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
}

# Default Provider (ap-south-2)
provider "aws" {
  region = "ap-south-2"
}

# Aliased Provider for US East 1 (us-east-1)
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}
```

### Resource Configuration (`resource.tf`)

`resource.tf` provisions two AWS S3 buckets in different regions:
1. `aws_s3_bucket.india`: Created in `ap-south-2` using the **default** provider.
2. `aws_s3_bucket.usa`: Created in `us-east-1` using the **aliased** provider (`provider = aws.us_east_1`).

```hcl
# Uses Default Provider (ap-south-2)
resource "aws_s3_bucket" "india" {
  bucket = "terraform-multi-region-india-example"
}

# Uses Aliased Provider (us-east-1)
resource "aws_s3_bucket" "usa" {
  provider = aws.us_east_1

  bucket = "terraform-multi-region-usa-example"
}
```

---

## 🚀 Getting Started

### Prerequisites

- [Terraform CLI](https://developer.hashicorp.com/terraform/downloads) (v1.0+)
- AWS CLI configured with valid credentials (`aws configure`) or environment variables (`AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`).

### Execution Steps

1. **Initialize Terraform**
   Downloads the required AWS provider plugin:
   ```bash
   terraform init
   ```

2. **Generate and Review Execution Plan**
   Inspect the resources that Terraform will create across regions:
   ```bash
   terraform plan
   ```

3. **Apply Configuration**
   Provision the resources:
   ```bash
   terraform apply
   ```

4. **Clean Up Resources**
   Destroy all provisioned infrastructure when finished:
   ```bash
   terraform destroy
   ```

---

## 💡 Common Use Cases

1. **S3 Cross-Region Replication (CRR)**: Creating source and destination buckets in distinct regions.
2. **Global VPC Peering & Transit Gateways**: Interconnecting infrastructure across geographic zones.
3. **Disaster Recovery & AMI Replication**: Copying Machine Images or RDS snapshots across regions for failover ready setups.
4. **Multi-Account Infrastructure**: Using different provider configurations with distinct AWS IAM profiles or assumed roles (`assume_role`).

---

## 📐 Best Practices

- **Descriptive Alias Names**: Use meaningful alias names based on region or function (e.g., `us_east_1`, `dr_region`, `primary`).
- **Explicit Provider Reference in Modules**: When passing providers into reusable Terraform modules, use the `providers` meta-argument:
  ```hcl
  module "multi_region_app" {
    source = "./modules/app"

    providers = {
      aws.primary = aws
      aws.dr      = aws.us_east_1
    }
  }
  ```
- **Global Resource Names**: Keep in mind that certain AWS resource names (like S3 bucket names) are globally unique across all regions.
- **Provider Version Pinning**: Always pin your provider versions in `required_providers` to prevent unexpected breaking changes.
