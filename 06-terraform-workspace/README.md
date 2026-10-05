# Terraform Workspaces

This module demonstrates how to manage multiple isolated environments (`dev`, `staging`, `prod`) using **Terraform Workspaces** from a single set of Terraform configuration files.

---

## 📌 Overview

Terraform workspaces allow you to maintain multiple state files for a single configuration directory. By referencing the built-in interpolation variable `${terraform.workspace}`, you can dynamically alter resource configurations, file outputs, and tagging depending on the currently active workspace.

### Key Benefits
* **Environment Isolation**: Separate state files (`terraform.tfstate.d/<workspace>/terraform.tfstate`) prevent accidental environment overwrites.
* **Code Reusability**: Use the same `.tf` files to provision Infrastructure as Code (IaC) across Development, Staging, and Production.
* **Dynamic Resource Naming**: Compute resource names and tags based on the active workspace name.

---

## 📁 Directory Structure & File Breakdown

```
06-terraform-workspace/
├── .gitignore               # Excludes state files, cache, and generated files from git
├── README.md                # Module documentation
├── main.tf                  # Provider configs, local_file resource, and AWS EC2 instance
├── variables.tf             # Input variable definitions (aws_region, instance_type)
├── outputs.tf               # Terraform output definitions
├── data.tf                  # AWS Data sources (Amazon Linux 2023 AMI, default VPC & subnets)
└── terraform.tfvars         # Sample input variables values
```

### File Details

1. **[`main.tf`](main.tf)**:
   * **Required Providers**: `hashicorp/aws` (~> 5.0) and `hashicorp/local` (~> 2.5).
   * **`local_file.environment`**: Dynamically creates a file named `${terraform.workspace}.txt` (e.g., `dev.txt`, `prod.txt`) containing the workspace name.
   * **`aws_instance.web`**: Provisions an EC2 instance tagged dynamically as `${terraform.workspace}-web-server`.

2. **[`variables.tf`](variables.tf)**:
   * `aws_region`: Target AWS Region for provider deployment.
   * `instance_type`: EC2 instance family/size (defaults to `t3.micro`).

3. **[`outputs.tf`](outputs.tf)**:
   * `workspace`: Displays current active workspace name (`terraform.workspace`).
   * `instance_id`: ID of the provisioned EC2 instance.
   * `instance_type`: Type of the provisioned EC2 instance.
   * `instance_name`: Dynamically generated instance tag name.
   * `private_ip`: Private IP address of the EC2 instance.

4. **[`data.tf`](data.tf)**:
   * `aws_ami.amazon_linux`: Dynamically queries the latest Amazon Linux 2023 AMI for `x86_64` architecture.
   * `aws_vpc.default` & `aws_subnets.default`: Looks up the AWS Default VPC and associated default subnets.

5. **[`terraform.tfvars`](terraform.tfvars)**:
   * Stores default parameter overrides for local testing.

---

## 🛠️ Terraform Workspace Commands Cheat Sheet

| Command | Description |
| :--- | :--- |
| `terraform workspace list` | List all available workspaces (`*` indicates current workspace). |
| `terraform workspace show` | Output the name of the currently selected workspace. |
| `terraform workspace new <name>` | Create and switch to a new workspace. |
| `terraform workspace select <name>` | Switch to an existing workspace. |
| `terraform workspace delete <name>` | Delete an unused workspace (must be empty). |

---

## 🚀 Step-by-Step Execution Guide

### 1. Initialize Terraform
Initialize the working directory to download necessary provider plugins (`aws` and `local`):
```bash
terraform init
```

### 2. View Current Workspace
By default, Terraform operates in the `default` workspace:
```bash
terraform workspace show
# Output: default
```

### 3. Create New Workspaces
Create dedicated workspaces for `dev`, `staging`, and `prod`:
```bash
terraform workspace new dev
terraform workspace new staging
terraform workspace new prod
```

### 4. Switch Between Workspaces
To select and switch your working context to `dev`:
```bash
terraform workspace select dev
```

Confirm active workspace:
```bash
terraform workspace show
# Output: dev
```

### 5. Plan & Apply Infrastructure
When you run `terraform plan` or `terraform apply`, Terraform uses the isolated state for the currently active workspace:

```bash
terraform plan -var="aws_region=us-east-1"
terraform apply -var="aws_region=us-east-1" -auto-approve
```

* **Local File Creation**: `dev.txt` is created containing `Environment: dev`.
* **AWS Resource Creation**: An EC2 instance tagged `dev-web-server` is created.

### 6. Switch to `prod` Workspace
```bash
terraform workspace select prod
terraform apply -var="aws_region=us-east-1" -auto-approve
```

* **Local File Creation**: `prod.txt` is created containing `Environment: prod`.
* **AWS Resource Creation**: An EC2 instance tagged `prod-web-server` is created in isolated state.

---

## 🔒 State File Isolation & Clean Git Practice

### How State is Stored
* **`default` Workspace**: State is stored in `terraform.tfstate`.
* **Named Workspaces**: State files are saved separately under `terraform.tfstate.d/<workspace_name>/terraform.tfstate`.

### Git Exclusion (`.gitignore`)
To prevent committing sensitive state info or machine-specific binaries, `.gitignore` excludes:
* `.terraform/` directory
* State files (`*.tfstate`, `*.tfstate.*`, `terraform.tfstate.d/`)
* Generated environment files (`dev.txt`, `staging.txt`, `prod.txt`)
* Variable files containing sensitive values (`*.tfvars`)
