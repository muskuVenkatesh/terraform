# Terraform Meta-Argument: `for_each`

Welcome to the comprehensive hands-on practice guide for the Terraform **`for_each` Meta-Argument**.

---

## Table of Contents

1. [Overview & Purpose](#1-overview--purpose)
2. [Directory Layout](#2-directory-layout)
3. [Key Concepts of `for_each`](#3-key-concepts-of-for_each)
4. [4 Major Use Cases for `for_each`](#4-4-major-use-cases-for-for_each)
   - [Use Case 1: Iterating over a Set of Strings (`set(string)`)](#use-case-1-iterating-over-a-set-of-strings-setstring)
   - [Use Case 2: Iterating over a Map of Strings (`map(string)`)](#use-case-2-iterating-over-a-map-of-strings-mapstring)
   - [Use Case 3: Iterating over a Map of Objects (`map(object)`)](#use-case-3-iterating-over-a-map-of-objects-mapobject)
   - [Use Case 4: Transforming a List of Objects to a Map using `for`](#use-case-4-transforming-a-list-of-objects-to-a-map-using-for)
5. [Referencing `for_each` Resources & Outputs](#5-referencing-for_each-resources--outputs)
6. [`for_each` vs `count` (Why `for_each` is Preferred for Dynamic Maps)](#6-for_each-vs-count-why-for_each-is-preferred-for-dynamic-maps)
7. [Step-by-Step Hands-On Practice Guide](#7-step-by-step-hands-on-practice-guide)
8. [Best Practices & Common Pitfalls](#8-best-practices--common-pitfalls)

---

## 1. Overview & Purpose

The **`for_each` meta-argument** allows you to create multiple instances of a resource or module based on a **map** or a **set of strings**.

Unlike `count`, which indexes resources by integers (`0`, `1`, `2`), `for_each` indexes resources by unique **string keys** (e.g., `aws_iam_user.iam_users["alice"]` or `aws_instance.web_cluster["web"]`).

This makes your infrastructure resilient to additions, deletions, or reordering of items!

---

## 2. Directory Layout

```text
05-terraform-meta-arguements/02-foreach-meta-argmnt/
├── provider.tf          # Provider configuration (Local, Random, AWS)
├── variables.tf         # Declarations for sets, maps, and objects
├── terraform.tfvars     # Sample inputs for sets and maps
├── main.tf              # Hands-on for_each resource implementations
├── outputs.tf           # Map & key-value output expressions
├── .gitignore           # Git ignore rules for state and local outputs
└── README.md            # Detailed tutorial & practice guide
```

---

## 3. Key Concepts of `for_each`

| Concept | Description | Example |
| :--- | :--- | :--- |
| **`for_each` Value** | Must be a **map** or a **set of strings**. Lists are NOT directly supported. | `for_each = var.user_names` |
| **`each.key`** | The map key or the set member string. | `"alice"`, `"web"`, `"public_subnet_1"` |
| **`each.value`** | The map value (or set member string when iterating over a set). | `"10.0.1.0/24"` or `{ instance_type = "t3.micro" }` |
| **Resource Map** | Resources are stored as a map in state. | `local_file.user_profiles["alice"]` |

---

## 4. 4 Major Use Cases for `for_each`

### Use Case 1: Iterating over a Set of Strings (`set(string)`)

When iterating over a set of strings, `each.key` and `each.value` are identical:

```hcl
variable "user_names" {
  type    = set(string)
  default = ["alice", "bob", "charlie"]
}

resource "aws_iam_user" "iam_users" {
  for_each = var.user_names
  name     = "dev-${each.value}"
}
```

### Use Case 2: Iterating over a Map of Strings (`map(string)`)

`each.key` is the map key, `each.value` is the map string value:

```hcl
variable "subnet_cidrs" {
  type = map(string)
  default = {
    public_subnet  = "10.0.1.0/24"
    private_subnet = "10.0.10.0/24"
  }
}

resource "local_file" "subnets" {
  for_each = var.subnet_cidrs
  content  = "CIDR for ${each.key} is ${each.value}"
  filename = "${path.module}/generated_subnets/${each.key}.txt"
}
```

### Use Case 3: Iterating over a Map of Objects (`map(object)`)

Ideal for provisioning complex resources with unique configurations:

```hcl
variable "environment_servers" {
  type = map(object({
    instance_type = string
    role          = string
  }))
}

resource "aws_instance" "web_cluster" {
  for_each      = var.environment_servers
  instance_type = each.value.instance_type

  tags = {
    Name = "${each.key}-server"
    Role = each.value.role
  }
}
```

### Use Case 4: Transforming a List of Objects to a Map using `for`

Since `for_each` requires a map or set, convert a list of objects using a `for` expression (`{ for item in list : item.key => item }`):

```hcl
variable "s3_bucket_configs" {
  type = list(object({
    name    = string
    purpose = string
  }))
}

resource "local_file" "bucket_configs" {
  for_each = { for bucket in var.s3_bucket_configs : bucket.name => bucket }
  content  = "Bucket: ${each.key} | Purpose: ${each.value.purpose}"
  filename = "${path.module}/generated_buckets/${each.key}.txt"
}
```

---

## 5. Referencing `for_each` Resources & Outputs

When referencing resources created with `for_each`, access them via string keys or construct output maps using `for` expressions:

### 1. Specific Key Lookup
Access a single resource by its key:
```hcl
output "web_server_id" {
  value = aws_instance.web_cluster["web"].id
}
```

### 2. Map Output using `for` Expression
Construct a map of keys to resource attributes:
```hcl
output "all_server_ids" {
  value = { for key, instance in aws_instance.web_cluster : key => instance.id }
}
```

---

## 6. `for_each` vs `count` (Why `for_each` is Preferred for Dynamic Maps)

| Feature | `count` Meta-Argument | `for_each` Meta-Argument |
| :--- | :--- | :--- |
| **Addressing** | Integer Index (`resource[0]`, `resource[1]`) | Key Name (`resource["alice"]`, `resource["dev"]`) |
| **List Modification Impact** | ⚠️ High (Removing an item in the middle causes re-indexing of all trailing elements) | ✅ Safe (Removing an item only destroys that specific key without affecting others) |
| **Best For** | Uniform counts (`count = 3`) or boolean switches (`count = var.enabled ? 1 : 0`) | Collections of named items, maps, sets, or complex objects |

---

## 7. Step-by-Step Hands-On Practice Guide

### Step 1: Navigate to the `02-foreach-meta-argmnt` directory
```bash
cd 05-terraform-meta-arguements/02-foreach-meta-argmnt
```

### Step 2: Initialize Terraform
```bash
terraform init
```

### Step 3: Run Terraform Plan
Observe how Terraform keys every resource by its map key or set member name:
```bash
terraform plan
```

### Step 4: Apply Target Local Files
Test local file generation without requiring AWS credentials:
```bash
terraform apply -target=local_file.user_profiles -target=local_file.subnet_configs -target=local_file.server_specs -target=local_file.bucket_configs -auto-approve
```

### Step 5: Verify Generated Files
Check the output files created in local subdirectories:
```bash
ls -la generated_users/
ls -la generated_subnets/
ls -la generated_servers/
ls -la generated_buckets/
```

---

## 8. Best Practices & Common Pitfalls

1. **Always Use `toset()` when passing lists**: If a variable is a list, convert it using `toset(var.list)` before supplying it to `for_each`.
2. **Ensure Keys are Known at Plan Time**: The keys of your map/set MUST be known before `terraform apply` runs (they cannot depend on computed resource outputs).
3. **Use Map of Objects for Complex Resources**: Avoid parallel lists; combine attributes into a single `map(object({...}))` for clear and maintainable code.
