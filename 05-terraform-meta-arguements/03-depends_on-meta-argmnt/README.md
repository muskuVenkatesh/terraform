# Terraform Meta-Argument: `depends_on`

Welcome to the practice guide for the Terraform **`depends_on` Meta-Argument**.

---

## Table of Contents

1. [Overview & Purpose](#1-overview--purpose)
2. [Implicit vs Explicit Dependencies](#2-implicit-vs-explicit-dependencies)
3. [When to Use `depends_on`](#3-when-to-use-depends_on)
4. [Syntax & Implementation](#4-syntax--implementation)
5. [Step-by-Step Hands-On Practice Guide](#5-step-by-step-hands-on-practice-guide)
6. [Best Practices & Common Pitfalls](#6-best-practices--common-pitfalls)

---

## 1. Overview & Purpose

Terraform automatically builds a **Dependency Graph** by analyzing implicit references between resources.

However, when a resource dependency exists that Terraform **cannot automatically infer from code attributes**, you must use the **`depends_on` meta-argument** to enforce explicit execution ordering.

---

## 2. Implicit vs Explicit Dependencies

### Implicit Dependency (Automatic)
Terraform automatically detects that `aws_instance.web` depends on `aws_security_group.web_sg` because `aws_instance` directly references `aws_security_group.web_sg.id`:

```hcl
resource "aws_security_group" "web_sg" { name = "web-sg" }

resource "aws_instance" "web" {
  vpc_security_group_ids = [aws_security_group.web_sg.id] # Implicit reference!
}
```

### Explicit Dependency (Manual via `depends_on`)
When resource $B$ depends on resource $A$ completing, but resource $B$'s HCL code does not reference any attributes of resource $A$:

```hcl
resource "aws_iam_role_policy_attachment" "attach_s3" { ... }

resource "aws_instance" "web" {
  # ... No attribute reference to policy attachment ...

  depends_on = [
    aws_iam_role_policy_attachment.attach_s3
  ]
}
```

---

## 3. When to Use `depends_on`

1. **IAM Policy Attachments**: Waiting for an IAM policy attachment to take effect before creating EC2 instances or EKS worker nodes.
2. **Database Initialization**: Enforcing that a database schema or migration script runs after DB creation, but before application deployment.
3. **S3 Bucket Policies**: Ensuring S3 bucket access policies or KMS keys exist before uploading objects.
4. **Internet Gateways / NAT Gateways**: Ensuring VPC networking gateways exist before launching EC2 instances requiring internet connectivity.

---

## 4. Syntax & Implementation

`depends_on` accepts a list of resource or module references:

```hcl
resource "local_file" "app_config" {
  content  = "App Configuration"
  filename = "${path.module}/generated_step2_app_config.txt"

  depends_on = [
    local_file.db_init
  ]
}
```

---

## 5. Step-by-Step Hands-On Practice Guide

### Step 1: Navigate to the `03-depends_on-meta-argmnt` directory
```bash
cd 05-terraform-meta-arguements/03-depends_on-meta-argmnt
```

### Step 2: Initialize Terraform
```bash
terraform init
```

### Step 3: Run Terraform Plan
Review the plan and notice how Terraform constructs the execution graph:
```bash
terraform plan
```

### Step 4: Apply Target Local Files
Test execution order for local files:
```bash
terraform apply -target=local_file.db_init -target=local_file.app_config -auto-approve
```

---

## 6. Best Practices & Common Pitfalls

1. **Prefer Implicit Dependencies**: Only use `depends_on` when implicit attribute references are impossible. Overusing `depends_on` reduces Terraform's ability to run operations in parallel.
2. **Use Module Dependencies**: `depends_on` can be applied to entire `module` blocks.
3. **Avoid Circular Dependencies**: Resource $A$ cannot depend on Resource $B$ if Resource $B$ depends on Resource $A$.
