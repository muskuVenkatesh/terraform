# 05 - Terraform Meta-Arguments & Provisioners Master Guide

Meta-arguments and provisioners in Terraform are special constructs supported by Terraform for resource and module blocks. They alter how Terraform handles resource lifecycle, count, dependencies, provider configurations, and custom script execution.

---

## Meta-Arguments & Provisioners Overview

| Section | Description | Dedicated Directory |
| :--- | :--- | :--- |
| **`count`** | Creates multiple instances of a resource or module based on an integer count or boolean condition. | [`01-count/`](./01-count/README.md) |
| **`for_each`** | Creates multiple instances of a resource or module based on a map or set of strings. | [`02-foreach-meta-argmnt/`](./02-foreach-meta-argmnt/README.md) |
| **`depends_on`** | Explicitly specifies hidden resource execution dependencies. | [`03-depends_on-meta-argmnt/`](./03-depends_on-meta-argmnt/README.md) |
| **`lifecycle`** | Customizes creation, destruction, and update behaviors (`create_before_destroy`, `prevent_destroy`, `ignore_changes`, `replace_triggered_by`). | [`04-lifecycle-meta-argmnt/`](./04-lifecycle-meta-argmnt/README.md) |
| **`provider`** | Specifies a non-default or aliased provider configuration for multi-region or multi-account deployments. | [`05-provider-meta-argmnt/`](./05-provider-meta-argmnt/README.md) |
| **`provisioners`** | Executes local or remote scripts/commands (`local-exec`, `remote-exec`, `file`, `connection`). | [`06-provisioners-meta-argmnt/`](./06-provisioners-meta-argmnt/README.md) |

---

## Practice Modules

1. [**`count` Meta-Argument Practice & Tutorial**](./01-count/README.md): Step-by-step guide covering `count.index`, list iteration, conditional resource toggles (`1` vs `0`), splat operators `[*]`, and comparisons with `for_each`.
2. [**`for_each` Meta-Argument Practice & Tutorial**](./02-foreach-meta-argmnt/README.md): Step-by-step guide covering `set(string)`, `map(string)`, `map(object)`, list-to-map conversion with `for`, `each.key`, `each.value`, and outputs.
3. [**`depends_on` Meta-Argument Practice & Tutorial**](./03-depends_on-meta-argmnt/README.md): Practical guide covering implicit vs explicit dependencies, IAM policy attachments, database initialization order, and dependency graph execution.
4. [**`lifecycle` Meta-Argument Practice & Tutorial**](./04-lifecycle-meta-argmnt/README.md): Complete guide on `create_before_destroy`, `prevent_destroy`, `ignore_changes`, and `replace_triggered_by`.
5. [**`provider` Meta-Argument Practice & Tutorial**](./05-provider-meta-argmnt/README.md): Practice guide covering default vs aliased providers, multi-region AWS deployments (`us-east-1`, `us-west-2`, `eu-central-1`), and cross-region resource mapping.
6. [**`provisioners` Practice & Tutorial**](./06-provisioners-meta-argmnt/README.md): In-depth guide covering `local-exec`, `remote-exec`, `file` provisioners, SSH `connection` blocks, creation-time vs destroy-time execution, and `null_resource` usage.
