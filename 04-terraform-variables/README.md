# Master Terraform Variables: From Scratch to Advanced Production Best Practices

Welcome to the complete, hands-on, step-by-step guide to **Terraform Variables**. This tutorial is designed for developers, DevOps engineers, and cloud architects who want to understand how variables work in Terraform, how value injection works across different sources, how variable precedence works, and how to structure production-grade Terraform projects cleanly and securely.

---

## Table of Contents

1. [Project Overview & Directory Structure](#1-project-overview--directory-structure)
2. [What are Terraform Variables and Why Use Them?](#2-what-are-terraform-variables-and-why-use-them)
3. [Terraform Variable Syntax & Declaration](#3-terraform-variable-syntax--declaration)
4. [Data Types in Terraform Variables](#4-data-types-in-terraform-variables)
5. [5 Ways to Provide Variable Values](#5-5-ways-to-provide-variable-values)
6. [Terraform Variable Precedence (The Ultimate Rule)](#6-terraform-variable-precedence-the-ultimate-rule)
7. [Step-by-Step Precedence Hands-On Experiment](#7-step-by-step-precedence-hands-on-experiment)
8. [Practical Hands-On Infrastructure Example](#8-practical-hands-on-infrastructure-example)
9. [Advanced Variable Concepts](#9-advanced-variable-concepts)
10. [Input Variables vs Local Values vs Outputs](#10-input-variables-vs-local-values-vs-outputs)
11. [Secure Secrets Handling in Terraform](#11-secure-secrets-handling-in-terraform)
12. [Common Mistakes to Avoid](#12-common-mistakes-to-avoid)
13. [Production Best Practices](#13-production-best-practices)
14. [Complete Command Reference](#14-complete-command-reference)

---

## 1. Project Overview & Directory Structure

A standard Terraform project separates configuration code, variable declarations, default variable assignments, and outputs into separate files.

### Directory Layout

```text
04-terraform-variables/
├── provider.tf          # Required providers & provider configurations
├── variables.tf         # Variable declarations (Types, Defaults, Validation rules)
├── terraform.tfvars     # Default auto-loaded variable values
├── dev.tfvars           # Custom variable values for Development environment
├── prod.tfvars          # Custom variable values for Production environment
├── secrets.tfvars.json  # Machine-readable JSON variable definition file
├── main.tf              # Main infrastructure code & local value calculations
├── outputs.tf           # Output declarations (Exposing resource data & secrets)
└── README.md            # Complete tutorial & documentation
```

### Purpose of Each File

| File Name | Purpose | Why We Use It |
| :--- | :--- | :--- |
| `provider.tf` | Declares required provider plugins (AWS, Local, Random) and Terraform versions. | Keeps provider definitions isolated from resource configuration. |
| `variables.tf` | Defines all input variable schemas, data types, descriptions, default values, and validation rules. | Acts as the formal interface/contract for the Terraform module. |
| `terraform.tfvars` | Contains default key-value pairs for variables defined in `variables.tf`. | Automatically loaded by Terraform without requiring extra command CLI flags. |
| `dev.tfvars` / `prod.tfvars` | Environment-specific variable definition files. | Allows deploying the exact same HCL code to different environments with different parameters. |
| `secrets.tfvars.json` | JSON-formatted variable definitions file. | Ideal for automated CI/CD pipelines and script-generated configurations. |
| `main.tf` | Defines infrastructure resources (`aws_s3_bucket`, `aws_instance`, `local_file`) and `locals`. | The core implementation file where resources consume variable inputs. |
| `outputs.tf` | Defines values to return after `terraform apply`. | Exposes useful resource metadata (IP addresses, bucket names, endpoint URLs) to users or parent modules. |

---

## 2. What are Terraform Variables and Why Use Them?

### What are Terraform Variables?

In Terraform, **Input Variables** serve as parameters for your infrastructure modules. Think of them like function arguments in programming languages (e.g., Python, JavaScript, or Java).

Without variables, your Terraform code is static and hardcoded:
```hcl
# Hardcoded - Bad Practice!
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
}
```

With variables, your Terraform code becomes dynamic and reusable:
```hcl
# Parameterized - Good Practice!
resource "aws_instance" "web" {
  ami           = var.ami_id
  instance_type = var.instance_type
}
```

### Why Use Variables?

1. **Reusability (DRY Principle)**: Write code once, deploy it across Development, Staging, and Production by passing different variable files.
2. **Maintainability**: Update a single variable value in `terraform.tfvars` instead of searching and replacing strings across dozens of `.tf` files.
3. **Security**: Keep sensitive credentials (API tokens, passwords) out of source code by passing them dynamically via environment variables or secret vaults.
4. **Validation & Type Safety**: Ensure invalid configurations (e.g., invalid AWS region or instance count = -5) are caught at `terraform plan` time before touching cloud infrastructure.

---

## 3. Terraform Variable Syntax & Declaration

Variables are declared in `variables.tf` using the `variable` block syntax.

### Anatomy of a Variable Block

```hcl
variable "variable_name" {
  type        = string                 # Data type constraint (Optional but strongly recommended)
  description = "Human-readable label" # Documentation string
  default     = "default_value"        # Fallback value if no value is supplied (Optional)
  sensitive   = false                  # Mask value in plan/apply terminal output (Optional)

  # Custom validation rule (Optional)
  validation {
    condition     = length(var.variable_name) > 3
    error_message = "The variable_name must be longer than 3 characters."
  }
}
```

### Default vs Required Variables

* **Default Variable**: Includes a `default = "..."` attribute. If the user does not pass a value, Terraform uses the default value.
* **Required Variable**: Omits the `default` attribute. If the user does not supply a value via `terraform.tfvars`, CLI, or `TF_VAR_*`, Terraform **stops and interactively prompts the user** for a value.

---

## 4. Data Types in Terraform Variables

Terraform supports primitive, collection, structural, and optional types.

### A. Primitive Types

| Type | Description | Example Declaration | Example Value |
| :--- | :--- | :--- | :--- |
| `string` | Text characters | `type = string` | `"us-east-1"` |
| `number` | Whole numbers or decimals | `type = number` | `3` or `3.14` |
| `bool` | Boolean truth values | `type = bool` | `true` or `false` |

```hcl
variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_count" {
  type    = number
  default = 2
}

variable "enable_monitoring" {
  type    = bool
  default = true
}
```

### B. Collection Types

| Type | Description | Uniqueness & Ordering | Example Value |
| :--- | :--- | :--- | :--- |
| `list(<TYPE>)` | Ordered sequence of values | Allows duplicates, ordered by index | `["us-east-1a", "us-east-1b"]` |
| `set(<TYPE>)` | Unordered collection of unique values | No duplicates allowed | `[80, 443, 22]` |
| `map(<TYPE>)` | Key-value dictionary | Keys must be strings | `{ dev = "t3.micro", prod = "t3.medium" }` |

```hcl
variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b"]
}

variable "allowed_ports" {
  type    = set(number)
  default = [80, 443, 22]
}

variable "instance_types" {
  type = map(string)
  default = {
    dev  = "t3.micro"
    prod = "t3.medium"
  }
}
```

### C. Structural Types (`object` & `map(object)`)

An `object` is a complex schema that groups multiple attributes of different types together.

```hcl
variable "database_config" {
  type = object({
    name              = string
    port              = number
    allocated_storage = number
    multi_az          = optional(bool, false) # Optional attribute with default
    backup_retention  = optional(number, 7)    # Optional attribute with default
  })
  default = {
    name              = "appdb"
    port              = 5432
    allocated_storage = 20
  }
}
```

---

## 5. 5 Ways to Provide Variable Values

Terraform can accept variable values from 5 different sources.

### Method A: Default Values in `variables.tf`

Defined directly in the `variable` block declaration:
```hcl
variable "environment" {
  type    = string
  default = "dev"
}
```

### Method B: `terraform.tfvars` File (Auto-loaded)

Terraform automatically searches for and loads any file named `terraform.tfvars` or `terraform.tfvars.json` in the current directory:
```hcl
# terraform.tfvars
environment  = "dev"
project_name = "my-terraform-lab"
```

### Method C: Custom `.tfvars` Files (`-var-file`)

Useful when separating environments into `dev.tfvars`, `staging.tfvars`, and `prod.tfvars`:
```bash
terraform plan -var-file="dev.tfvars"
terraform apply -var-file="prod.tfvars"
```

### Method D: Command-Line Flags (`-var`)

Supply values directly on the command line during execution:
```bash
terraform plan -var="environment=prod" -var="instance_count=5"
```

### Method E: Environment Variables (`TF_VAR_name`)

Terraform inspects host environment variables starting with `TF_VAR_<variable_name>`:
```bash
export TF_VAR_environment="prod"
export TF_VAR_db_password="SuperSecretPassword123!"
terraform plan
```

---

## 6. Terraform Variable Precedence (The Ultimate Rule)

When the exact same variable is defined across multiple sources, Terraform resolves conflict using a strict **Precedence Hierarchy**.

> [!IMPORTANT]
> **Variable Precedence Order (Highest to Lowest):**
> 1. **CLI `-var` or `-var-file` flags** (If multiple flags are specified, the last flag evaluated wins)
> 2. **`*.auto.tfvars` or `*.auto.tfvars.json` files** (Processed alphabetically)
> 3. **`terraform.tfvars` or `terraform.tfvars.json` file**
> 4. **`TF_VAR_name` Environment Variables**
> 5. **`default` value** in variable declaration block

### Precedence Summary Table

| Rank | Source | Command / File Example | Overrides |
| :---: | :--- | :--- | :--- |
| **1 (Highest)** | Command Line `-var` / `-var-file` | `terraform plan -var="environment=prod"` | All lower sources (2, 3, 4, 5) |
| **2** | Auto-loaded `*.auto.tfvars` | `prod.auto.tfvars` | `terraform.tfvars`, `TF_VAR_*`, Defaults |
| **3** | Default `terraform.tfvars` | `terraform.tfvars` | `TF_VAR_*`, Defaults |
| **4** | Environment Variable | `export TF_VAR_environment="prod"` | Default values |
| **5 (Lowest)** | Default Attribute | `default = "dev"` in `variables.tf` | None (Fallback baseline) |

---

## 7. Step-by-Step Precedence Hands-On Experiment

Let's test precedence on the `environment` variable step-by-step.

### Step 1: Default Value Baseline
If no external values are provided, Terraform falls back to `default = "dev"` in `variables.tf`.

### Step 2: Environment Variable (`TF_VAR_environment`)
Set an environment variable in your terminal:
```bash
export TF_VAR_environment="staging"
export TF_VAR_db_password="MySecretPassword123!"
terraform plan
```
* **Result**: Terraform uses `environment = "staging"` (overriding `variables.tf` default).

### Step 3: `terraform.tfvars` File
In `terraform.tfvars`, we set: `environment = "dev"`.
```bash
terraform plan
```
* **Result**: Terraform uses `environment = "dev"` (overriding `TF_VAR_environment="staging"`).

### Step 4: Custom `-var-file="prod.tfvars"`
In `prod.tfvars`, we set: `environment = "prod"`.
```bash
terraform plan -var-file="prod.tfvars"
```
* **Result**: Terraform uses `environment = "prod"` (overriding `terraform.tfvars`).

### Step 5: Command Line `-var="environment=override-env"`
Run:
```bash
terraform plan -var-file="prod.tfvars" -var="environment=override-env"
```
* **Result**: Terraform uses `environment = "override-env"` (**CLI `-var` wins over every other source!**).

Unset environment variable when done:
```bash
unset TF_VAR_environment
```

---

## 8. Practical Hands-On Infrastructure Example

Our project contains complete HCL resources in `main.tf` that utilize variables in realistic cloud patterns.

### Main Infrastructure Logic (`main.tf`)

```hcl
locals {
  name_prefix = "${var.project_name}-${var.environment}"
  
  # Map lookup fallback
  selected_instance_type = lookup(var.instance_types, var.environment, "t3.micro")

  merged_tags = merge(
    var.common_tags,
    {
      Environment = var.environment
      Project     = var.project_name
    }
  )
}

# Generates configuration summary locally
resource "local_file" "config_summary" {
  filename = "${path.module}/generated_config.txt"
  content  = <<-EOT
    Project Name       : ${var.project_name}
    Environment        : ${var.environment}
    AWS Region         : ${var.aws_region}
    Instance Type      : ${local.selected_instance_type}
    Instance Count     : ${var.instance_count}
    Allowed Ports      : ${join(", ", [for p in var.allowed_ports : tostring(p)])}
  EOT
}
```

---

## 9. Advanced Variable Concepts

### A. Variable Validation Rules
You can enforce business rules using `validation` blocks with condition expressions and custom error messages.

```hcl
variable "project_name" {
  type    = string
  default = "demo-app"

  # Rule 1: Length check
  validation {
    condition     = length(var.project_name) >= 3 && length(var.project_name) <= 20
    error_message = "Project name must be between 3 and 20 characters long."
  }

  # Rule 2: Regex check for lowercase alphanumeric characters and hyphens
  validation {
    condition     = can(regex("^[a-z0-9-]+$", var.project_name))
    error_message = "Project name can only contain lowercase letters, numbers, and hyphens."
  }
}
```

If a user inputs `"INVALID_PROJECT_NAME!"`, `terraform plan` immediately fails with your exact `error_message`.

### B. Sensitive Variables
Marking a variable as `sensitive = true` prevents Terraform from outputting plaintext secrets in CLI output or logs.

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

Terminal output during `plan` or `apply`:
```text
  + db_password = (sensitive value)
```

> [!CAUTION]
> Marking a variable as `sensitive = true` hides it from terminal screens, but the value is STILL recorded in plain text inside the `terraform.tfstate` state file. Never commit state files to source control!

### C. `.tfvars` vs `.tfvars.json`
Terraform natively supports JSON variable files. This is useful when variable files are generated dynamically by scripts or CI/CD pipelines (e.g., Python, Node.js, Jenkins).

```json
{
  "api_secret_key": "json-secret-key-prod-9988",
  "db_password": "JsonSecurePassword456!"
}
```

Usage:
```bash
terraform plan -var-file="secrets.tfvars.json"
```

### D. Passing Variables to Child Modules
When building modular Terraform architectures, parent modules pass values to child module input variables:

```hcl
# Root main.tf
module "web_cluster" {
  source        = "./modules/ec2_cluster"
  environment   = var.environment
  instance_type = local.selected_instance_type
  cluster_size  = var.instance_count
}
```

---

## 10. Input Variables vs Local Values vs Outputs

 beginners often confuse Variables, Locals, and Outputs. Here is a clear decision matrix:

| Feature | Input Variables (`variables.tf`) | Local Values (`locals`) | Outputs (`outputs.tf`) |
| :--- | :--- | :--- | :--- |
| **Analogy** | Function Arguments | Internal Function Variables | Function Return Values |
| **Configurable by User?** | **YES** (via CLI, `.tfvars`, ENV) | **NO** (Calculated internally) | **NO** (Exposed externally) |
| **Primary Use Case** | Parameterizing infrastructure | Computing dynamic logic / DRY expressions | Exporting IDs, IPs, and endpoints |
| **Syntax Reference** | `var.variable_name` | `local.local_name` | `module.module_name.output_name` |

---

## 11. Secure Secrets Handling in Terraform

Storing passwords, tokens, and keys safely is a top priority in Cloud Engineering.

### Recommended Approaches for Secrets

1. **Environment Variables**: Use `export TF_VAR_db_password="..."` in ephemeral CI/CD runners (e.g., GitHub Actions Secrets, GitLab CI masking).
2. **External Secret Managers**: Fetch credentials dynamically at runtime using Terraform Data Sources:
   * **AWS Secrets Manager** (`aws_secretsmanager_secret_version`)
   * **AWS SSM Parameter Store** (`aws_ssm_parameter`)
   * **HashiCorp Vault** (`vault_generic_secret`)
3. **Git Hygiene**: Always list sensitive `.tfvars` files in `.gitignore`:
   ```text
   *.tfvars
   *.tfvars.json
   *.tfstate
   *.tfstate.backup
   ```

---

## 12. Common Mistakes to Avoid

1. **Hardcoding Values in Resource Blocks**: Defeats the purpose of Terraform automation.
2. **Committing `.tfvars` containing passwords to Git**: Exposes secrets in repository history.
3. **Omitting `type` constraints**: Disables Terraform's type checking system and can lead to unexpected runtime type coercion.
4. **Confusing Variables and Locals**: Trying to set `var.something` inside `main.tf` logic (variables are read-only inputs!).
5. **Ignoring Sensitive Flags**: Forgetting to add `sensitive = true` on API keys or passwords, leaking secrets into build logs.

---

## 13. Production Best Practices

* **Always Specify Type and Description**: Make your code self-documenting for team members.
* **Keep `variables.tf` Organized**: Group related variables with standard header comments (`# Primitives`, `# Networking`, `# Database`).
* **Use `locals` for Transformations**: Keep `variables.tf` pure and perform string concatenation or lookup logic inside `main.tf` `locals`.
* **Standardize Environment `.tfvars`**: Maintain identical keys in `dev.tfvars`, `staging.tfvars`, and `prod.tfvars`.
* **Enforce Validation Rules**: Protect infrastructure from invalid inputs early in the CI/CD pipeline.

---

## 14. Complete Command Reference

Execute these commands in your project directory (`04-terraform-variables`):

### 1. `terraform init`
Initializes the working directory, downloads required provider plugins (`aws`, `local`, `random`), and prepares the backend.
```bash
terraform init
```

### 2. `terraform fmt`
Formats all `.tf` files to adhere to standard HCL canonical formatting guidelines.
```bash
terraform fmt
```

### 3. `terraform validate`
Checks the syntactical correctness of your HCL code, variable declarations, and type consistency without contacting cloud providers.
```bash
terraform validate -var="db_password=TestPass123!"
```

### 4. `terraform plan`
Generates an execution plan showing what resources Terraform will create, update, or destroy.

```bash
# Test using auto-loaded terraform.tfvars
terraform plan

# Test using dev environment variables
terraform plan -var-file="dev.tfvars"

# Test using prod environment variables
terraform plan -var-file="prod.tfvars"

# Test overriding via CLI flag
terraform plan -var-file="prod.tfvars" -var="environment=prod" -var="instance_count=3"
```

### 5. `terraform apply`
Executes the plan to create or modify resources.
```bash
terraform apply -var-file="dev.tfvars" -auto-approve
```

### 6. `terraform destroy`
Destroys all infrastructure managed by the current project.
```bash
terraform destroy -var-file="dev.tfvars" -auto-approve
```

---

*Congratulations! You now have a complete, production-ready foundation in Terraform variables.*
