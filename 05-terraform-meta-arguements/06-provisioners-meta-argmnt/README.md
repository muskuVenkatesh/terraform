# Terraform Provisioners: `local-exec`, `remote-exec`, `file` & `connection`

Welcome to the practice guide for **Terraform Provisioners**.

---

## Table of Contents

1. [Overview & Purpose](#1-overview--purpose)
2. [Types of Provisioners](#2-types-of-provisioners)
   - [`local-exec`](#local-exec)
   - [`file`](#file)
   - [`remote-exec`](#remote-exec)
3. [The `connection` Block](#3-the-connection-block)
4. [Creation-Time vs Destroy-Time Provisioners](#4-creation-time-vs-destroy-time-provisioners)
5. [Error Handling (`on_failure`)](#5-error-handling-on_failure)
6. [Why Provisioners should be a Last Resort](#6-why-provisioners-should-be-a-last-resort)
7. [Step-by-Step Hands-On Practice Guide](#7-step-by-step-hands-on-practice-guide)

---

## 1. Overview & Purpose

**Provisioners** are used to execute scripts or shell commands on your local workstation or on a remote machine as part of resource creation or destruction.

---

## 2. Types of Provisioners

| Provisioner | Execution Location | Primary Purpose | Example Use Case |
| :--- | :--- | :--- | :--- |
| **`local-exec`** | Local machine running Terraform CLI | Execute local bash scripts, Ansible playbooks, or log creation | Saving IP addresses to a file |
| **`file`** | Copies from local to remote machine | Transfer configuration files or scripts via SSH/WinRM | Uploading app configuration to `/tmp` |
| **`remote-exec`** | Remote EC2 / VM instance | Run shell commands directly on the remote server via SSH | Running `apt-get update` or Docker commands |

---

## 3. The `connection` Block

The `connection` block defines how Terraform connects to remote resources (SSH for Linux, WinRM for Windows):

```hcl
connection {
  type        = "ssh"
  user        = "ec2-user"
  private_key = file("${path.module}/id_rsa")
  host        = self.public_ip
}
```

---

## 4. Creation-Time vs Destroy-Time Provisioners

### Creation-Time Provisioner (Default)
Runs when the resource is created. If a creation-time provisioner fails, the resource is marked **tainted**:

```hcl
provisioner "local-exec" {
  command = "echo 'Created resource ${self.id}'"
}
```

### Destroy-Time Provisioner (`when = destroy`)
Runs *before* the resource is destroyed:

```hcl
provisioner "local-exec" {
  when    = destroy
  command = "echo 'Destroying resource ${self.id}'"
}
```

---

## 5. Error Handling (`on_failure`)

By default, a provisioner failure causes `terraform apply` to fail:
- `on_failure = fail` (Default): Abort apply and mark resource tainted.
- `on_failure = continue`: Ignore provisioner errors and complete apply.

---

## 6. Why Provisioners should be a Last Resort

HashiCorp explicitly recommends using provisioners **only as a last resort** because:
1. They make Terraform configurations non-declarative.
2. Network connectivity failures can taint resources.
3. **Better Alternatives**: Use `user_data` / `cloud-init`, Packer custom images, or Ansible / SaltStack.

---

## 7. Step-by-Step Hands-On Practice Guide

### Step 1: Navigate to the directory
```bash
cd 05-terraform-meta-arguements/06-provisioners-meta-argmnt
```

### Step 2: Initialize Terraform
```bash
terraform init
```

### Step 3: Run Terraform Plan
```bash
terraform plan
```

### Step 4: Test `local-exec` Provisioner
```bash
terraform apply -target=local_file.sample_app -target=null_resource.inventory_builder -auto-approve
```

### Step 5: Verify Generated Log Files
```bash
cat generated_outputs/local_exec_log.txt
cat generated_outputs/ansible_inventory.ini
```
