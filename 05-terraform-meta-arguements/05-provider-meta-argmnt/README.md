# Terraform Meta-Argument: `provider`

Welcome to the practice guide for the Terraform **`provider` Meta-Argument**.

---

## Table of Contents

1. [Overview & Purpose](#1-overview--purpose)
2. [Default vs Aliased Providers](#2-default-vs-aliased-providers)
3. [When to Use `provider`](#3-when-to-use-provider)
4. [Syntax & Implementation](#4-syntax--implementation)
5. [Step-by-Step Hands-On Practice Guide](#5-step-by-step-hands-on-practice-guide)
6. [Best Practices & Common Pitfalls](#6-best-practices--common-pitfalls)

---

## 1. Overview & Purpose

By default, resources use the default (un-aliased) provider configuration for their type (e.g., `provider "aws"`).

The **`provider` meta-argument** specifies a non-default or **aliased provider** for a resource or module. This allows you to manage infrastructure across multiple AWS regions, multiple cloud accounts, or different provider configurations within the same Terraform workspace.

---

## 2. Default vs Aliased Providers

### Default Provider
```hcl
provider "aws" {
  region = "us-east-1"
}
```

### Aliased Provider
```hcl
provider "aws" {
  alias  = "us_west_2"
  region = "us-west-2"
}
```

---

## 3. When to Use `provider`

1. **Multi-Region Deployments**: Provisioning primary resources in `us-east-1` and disaster recovery (DR) resources in `us-west-2`.
2. **Multi-Account Access**: Deploying resources into separate AWS accounts (e.g., Prod vs Audit log storage) using assumed IAM roles.
3. **Cross-Region Replication**: Creating S3 cross-region replication buckets or CloudFront ACM certificates in `us-east-1` while infrastructure runs in `eu-west-1`.

---

## 4. Syntax & Implementation

```hcl
resource "aws_s3_bucket" "secondary_bucket" {
  provider = aws.us_west_2 # Specifies aliased provider

  bucket = "my-west-bucket"
}
```

---

## 5. Step-by-Step Hands-On Practice Guide

### Step 1: Navigate to the `05-provider-meta-argmnt` directory
```bash
cd 05-terraform-meta-arguements/05-provider-meta-argmnt
```

### Step 2: Initialize Terraform
```bash
terraform init
```

### Step 3: Run Terraform Plan
Observe how Terraform maps resources to their respective regional provider aliases (`aws.us_west_2`, `aws.eu_central_1`):
```bash
terraform plan
```

---

## 6. Best Practices & Common Pitfalls

1. **Keep Provider Aliases Descriptive**: Name aliases clearly (e.g., `aws.us_west_2` or `aws.production`).
2. **Passing Providers to Modules**: Use `providers = { aws = aws.us_west_2 }` when instantiating child modules.
