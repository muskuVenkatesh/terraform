# Terraform Meta-Argument: `lifecycle`

Welcome to the practice guide for the Terraform **`lifecycle` Meta-Argument**.

---

## Table of Contents

1. [Overview & Purpose](#1-overview--purpose)
2. [Lifecycle Rules Summary](#2-lifecycle-rules-summary)
3. [Key Concepts & Deep Dive](#3-key-concepts--deep-dive)
   - [`create_before_destroy`](#create_before_destroy)
   - [`prevent_destroy`](#prevent_destroy)
   - [`ignore_changes`](#ignore_changes)
   - [`replace_triggered_by`](#replace_triggered_by)
4. [Step-by-Step Hands-On Practice Guide](#4-step-by-step-hands-on-practice-guide)
5. [Best Practices & Common Pitfalls](#5-best-practices--common-pitfalls)

---

## 1. Overview & Purpose

By default, Terraform manages resources using standard CRUD lifecycle rules (Destroy then Create for updates requiring replacement, modify in-place when possible).

The **`lifecycle` meta-argument** is a nested block inside a resource definition that allows you to override Terraform's default lifecycle behaviors.

---

## 2. Lifecycle Rules Summary

| Lifecycle Attribute | Purpose | Common Use Case |
| :--- | :--- | :--- |
| **`create_before_destroy`** | Creates the new replacement resource before destroying the existing one. | Zero-downtime updates (SG, AMI replacements) |
| **`prevent_destroy`** | Rejects plan/apply operations that attempt to destroy the resource. | Protecting Prod DBs, Primary S3 buckets |
| **`ignore_changes`** | Ignores changes/drift to specified resource attributes. | Autoscaling, external tag updates, secret rotations |
| **`replace_triggered_by`** | Forces replacement when specified referenced attributes change. | Re-deploying app instances when config updates |

---

## 3. Key Concepts & Deep Dive

### `create_before_destroy`
```hcl
resource "local_file" "app_config" {
  filename = "config.txt"
  content  = "v1.0"

  lifecycle {
    create_before_destroy = true
  }
}
```

### `prevent_destroy`
```hcl
resource "local_file" "database_dump" {
  filename = "backup.txt"

  lifecycle {
    prevent_destroy = true
  }
}
```

### `ignore_changes`
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345"
  instance_type = "t3.micro"

  tags = {
    Name           = "web"
    LastDeployedBy = "Jenkins"
  }

  lifecycle {
    ignore_changes = [
      tags["LastDeployedBy"]
    ]
  }
}
```

---

## 4. Step-by-Step Hands-On Practice Guide

### Step 1: Navigate to the `04-lifecycle-meta-argmnt` directory
```bash
cd 05-terraform-meta-arguements/04-lifecycle-meta-argmnt
```

### Step 2: Initialize Terraform
```bash
terraform init
```

### Step 3: Run Terraform Plan
```bash
terraform plan
```

### Step 4: Apply Target Local Files
```bash
terraform apply -target=local_file.zero_downtime_config -target=local_file.protected_database_dump -auto-approve
```

---

## 5. Best Practices & Common Pitfalls

1. **Be careful with `prevent_destroy`**: You must comment out `prevent_destroy = true` before running `terraform destroy` when decommissioning infrastructure.
2. **Use `ignore_changes = all` cautiously**: Ignoring all changes stops Terraform from enforcing drift detection on the entire resource.
