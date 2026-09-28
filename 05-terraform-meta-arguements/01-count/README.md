# Terraform Meta-Argument: `count`

Welcome to the comprehensive hands-on practice guide for the Terraform **`count` Meta-Argument**.

---

## Table of Contents

1. [Overview & Purpose](#1-overview--purpose)
2. [Directory Layout](#2-directory-layout)
3. [Key Concepts of `count`](#3-key-concepts-of-count)
4. [4 Major Use Cases for `count`](#4-4-major-use-cases-for-count)
   - [Use Case 1: Simple Loop (Multiple Identical Resources)](#use-case-1-simple-loop-multiple-identical-resources)
   - [Use Case 2: Dynamic Naming with `count.index`](#use-case-2-dynamic-naming-with-countindex)
   - [Use Case 3: Iterating over Lists with `length()`](#use-case-3-iterating-over-lists-with-length)
   - [Use Case 4: Conditional Creation (Feature Toggle / Switch)](#use-case-4-conditional-creation-feature-toggle--switch)
5. [Referencing Counted Resources & Outputs](#5-referencing-counted-resources--outputs)
6. [`count` vs `for_each` (Crucial Differences)](#6-count-vs-for_each-crucial-differences)
7. [Step-by-Step Hands-On Practice Guide](#7-step-by-step-hands-on-practice-guide)
8. [Best Practices & Common Pitfalls](#8-best-practices--common-pitfalls)

---

## 1. Overview & Purpose

By default, a Terraform `resource` or `module` block defines a **single** infrastructure object.

When you need to create **multiple instances** of the same resource (e.g., 3 web servers, 5 IAM users, or optional bastion hosts), duplicating resource blocks manually violates the **DRY (Don't Repeat Yourself)** principle:

```hcl
# ❌ Bad Practice: Hardcoded duplication
resource "aws_instance" "web_1" { ... }
resource "aws_instance" "web_2" { ... }
resource "aws_instance" "web_3" { ... }
```

The **`count` meta-argument** tells Terraform to instantiate a resource or module block a specific number of times without repeating code.

---

## 2. Directory Layout

```text
05-terraform-meta-arguements/count/
├── provider.tf          # Required providers (Local, Random, AWS)
├── variables.tf         # Input variable declarations
├── terraform.tfvars     # Variable value definitions
├── main.tf              # Practical count meta-argument implementations
├── outputs.tf           # Splat [*] and index-based outputs
└── README.md            # Detailed tutorial & practice guide
```

---

## 3. Key Concepts of `count`

| Concept | Explanation | Example |
| :--- | :--- | :--- |
| **`count` argument** | Integer value defining how many resource instances Terraform creates. | `count = 3` |
| **`count.index` object** | A 0-based integer index available inside any resource block using `count`. | First instance: `0`, Second: `1`, Third: `2` |
| **Resource Array** | When `count` is set, Terraform manages resources as a zero-indexed list. | `aws_instance.web_servers[0]`, `aws_instance.web_servers[1]` |
| **Splat Operator `[*]`** | Syntax used to fetch an attribute from all instances in a count list. | `aws_instance.web_servers[*].id` |

---

## 4. 4 Major Use Cases for `count`

### Use Case 1: Simple Loop (Multiple Identical Resources)

Creates $N$ instances of a resource with identical attributes:

```hcl
resource "aws_instance" "web_servers" {
  count         = 3
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
}
```

### Use Case 2: Dynamic Naming with `count.index`

Use `count.index` to generate unique names or tags for each instance:

```hcl
resource "local_file" "server_logs" {
  count    = var.server_count
  content  = "Log file initialized for server ${count.index + 1}"
  filename = "${path.module}/generated_logs/server_${count.index + 1}.log"
}
```

### Use Case 3: Iterating over Lists with `length()`

Combine `count` with `length(var.list)` and `var.list[count.index]` to iterate over a list:

```hcl
variable "iam_user_names" {
  type    = list(string)
  default = ["dev-alice", "dev-bob", "dev-charlie"]
}

resource "aws_iam_user" "team_members" {
  count = length(var.iam_user_names)
  name  = var.iam_user_names[count.index]
}
```

### Use Case 4: Conditional Creation (Feature Toggle / Switch)

Use a ternary expression (`condition ? 1 : 0`) to conditionally deploy infrastructure:

```hcl
variable "enable_bastion_host" {
  type    = bool
  default = true
}

resource "local_file" "bastion_config" {
  count    = var.enable_bastion_host ? 1 : 0
  content  = "Bastion host active"
  filename = "${path.module}/generated_configs/bastion_host.txt"
}
```

- If `enable_bastion_host = true` $\rightarrow$ `count = 1` (Resource created)
- If `enable_bastion_host = false` $\rightarrow$ `count = 0` (Resource destroyed / omitted)

---

## 5. Referencing Counted Resources & Outputs

When referencing resources created with `count`, you **cannot** reference them directly as `aws_instance.web_servers.id`. You must use one of the following methods:

### 1. Specific Index Lookup
Access a single instance by its index:
```hcl
output "first_server_id" {
  value = aws_instance.web_servers[0].id
}
```

### 2. Splat Operator (`[*]`)
Collect an attribute from all instances into a list:
```hcl
output "all_server_ids" {
  value = aws_instance.web_servers[*].id
}
```

### 3. Safe Conditional Access
Prevent index out of bounds errors when `count` might be `0`:
```hcl
output "bastion_file" {
  value = length(local_file.bastion_config) > 0 ? local_file.bastion_config[0].filename : "Not Created"
}
```

---

## 6. `count` vs `for_each` (Crucial Differences)

| Feature | `count` Meta-Argument | `for_each` Meta-Argument |
| :--- | :--- | :--- |
| **Data Types** | Integer numbers (`number` or ternary condition) | Map or Set of Strings |
| **Indexing** | Integer-based index (`0`, `1`, `2`) | Map key or Set value string |
| **Order Sensitivity** | ⚠️ High (Removing an item shifts all subsequent indices) | ✅ None (Key-based tracking) |
| **Best Use Case** | Identical resources or Boolean toggles (`1` or `0`) | Collections of items with distinct names/keys |

> ⚠️ **Warning on List Removal with `count`**:  
> If you create IAM users `["alice", "bob", "charlie"]` using `count` and later remove `"alice"` from the middle of the list:
> - Index `0` (`alice`) gets destroyed.
> - Index `1` (`bob`) becomes index `0`, forcing Terraform to modify or recreate `bob`.
> - For distinct items, prefer **`for_each`**. Use **`count`** primarily for numeric counts or conditional flags!

---

## 7. Step-by-Step Hands-On Practice Guide

Follow these steps in your terminal to test this code locally:

### Step 1: Navigate to the `count` directory
```bash
cd 05-terraform-meta-arguements/count
```

### Step 2: Initialize Terraform
```bash
terraform init
```

### Step 3: Run Terraform Plan
Observe how Terraform plans to create 3 server logs, 3 user configs, 1 bastion file, IAM users, and EC2 instances:
```bash
terraform plan
```

### Step 4: Apply Configuration (Targeting Local Files)
You can test the local file resources without requiring AWS credentials:
```bash
terraform apply -target=local_file.server_logs -target=local_file.user_configs -target=local_file.bastion_config -auto-approve
```

### Step 5: Verify Generated Files
Check the created files in your file system:
```bash
ls -la generated_logs/
ls -la generated_users/
ls -la generated_configs/
```

### Step 6: Test Conditional Count Toggle
Pass `enable_bastion_host=false` via CLI to see `count = 0` in action:
```bash
terraform apply -var="enable_bastion_host=false" -target=local_file.bastion_config -auto-approve
```

---

## 8. Best Practices & Common Pitfalls

1. **Use `count` for On/Off Switches**: Use `count = var.enabled ? 1 : 0` as the standard design pattern for optional modules/resources.
2. **Avoid `count` for Dynamic Item Sets**: If items can be inserted/removed from the middle of a list, use `for_each` instead.
3. **Always use Splat `[*]` for Outputs**: When returning attributes from counted resources, use `resource[*].attribute`.
4. **Use `count.index + 1` for 1-based Naming**: Since `count.index` starts at `0`, add `1` when creating human-friendly names (e.g., `server-1`).
