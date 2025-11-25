# Terraform Implementation

This directory contains the Terraform implementation of the S3 bucket infrastructure.

## Overview

Terraform is an open-source Infrastructure as Code tool by HashiCorp. It uses declarative configuration files written in HashiCorp Configuration Language (HCL).

## What's Created

- **S3 Bucket** with a unique name (using random suffix)
- **Versioning** enabled for object version history
- **Server-Side Encryption** using AES256
- **Public Access Block** to prevent accidental public exposure

## Prerequisites

- [Terraform](https://www.terraform.io/downloads) installed (>= 1.0)
- AWS CLI configured with valid credentials
- Appropriate IAM permissions for S3

See [Local Environment Setup](../docs/02-local-environment.md) for installation instructions.

## Files

- `main.tf` - Main infrastructure configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `deploy.sh` - Helper script to deploy
- `destroy.sh` - Helper script to destroy

## Quick Start

### Option 1: Using Helper Scripts

```bash
# Deploy infrastructure
./deploy.sh

# Destroy infrastructure when done
./destroy.sh
```

### Option 2: Manual Commands

```bash
# Initialize Terraform (first time only)
terraform init

# Preview changes
terraform plan

# Deploy infrastructure
terraform apply

# View outputs
terraform output

# Destroy infrastructure
terraform destroy
```

## Detailed Usage

### Initialize

Download providers and prepare working directory:

```bash
terraform init
```

This creates a `.terraform` directory with the AWS provider plugin.

### Plan

Preview what changes Terraform will make:

```bash
terraform plan
```

Review the plan to ensure it matches expectations.

### Apply

Create the infrastructure:

```bash
terraform apply
```

Type `yes` when prompted, or use auto-approve:

```bash
terraform apply -auto-approve
```

### View Outputs

After deployment, view the created resources:

```bash
terraform output
```

Example output:
```
bucket_arn = "arn:aws:s3:::iac-learning-bucket-abc12345"
bucket_name = "iac-learning-bucket-abc12345"
bucket_region = "us-east-1"
```

### Destroy

Remove all Terraform-managed resources:

```bash
terraform destroy
```

Type `yes` when prompted, or use auto-approve:

```bash
terraform destroy -auto-approve
```

## Customization

### Change AWS Region

```bash
terraform apply -var="aws_region=us-west-2"
```

Or edit `variables.tf` to change the default.

### Change Bucket Prefix

```bash
terraform apply -var="bucket_prefix=my-custom-prefix"
```

### Use Variables File

Create `terraform.tfvars`:

```hcl
aws_region    = "us-west-2"
bucket_prefix = "my-bucket"
environment   = "dev"
```

Then apply:

```bash
terraform apply
```

## State Management

Terraform stores state in `terraform.tfstate` (local backend by default).

### Important Notes

- **Never commit** `terraform.tfstate` to version control (already in .gitignore)
- State contains sensitive information and resource IDs
- For team collaboration, use remote backends

### Remote Backend (Optional)

For production or team use, configure remote state in `main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state-bucket"
    key    = "iac-learning/terraform.tfstate"
    region = "us-east-1"
  }
}
```

## Verification

Verify the bucket was created:

```bash
# Using Terraform output
BUCKET_NAME=$(terraform output -raw bucket_name)

# Check bucket exists
aws s3 ls | grep $BUCKET_NAME

# Verify versioning
aws s3api get-bucket-versioning --bucket $BUCKET_NAME

# Verify encryption
aws s3api get-bucket-encryption --bucket $BUCKET_NAME

# Verify public access block
aws s3api get-public-access-block --bucket $BUCKET_NAME
```

## Common Commands

```bash
# Format code
terraform fmt

# Validate configuration
terraform validate

# Show current state
terraform show

# List resources
terraform state list

# Refresh state
terraform refresh

# Import existing resource
terraform import aws_s3_bucket.learning_bucket bucket-name
```

## Troubleshooting

### Issue: Provider not found
```bash
# Re-initialize
terraform init -upgrade
```

### Issue: State locked
```bash
# If using local state and process was interrupted
rm .terraform.tfstate.lock.info

# If using remote state
terraform force-unlock <LOCK_ID>
```

### Issue: Changes detected when none expected
```bash
# Refresh state to sync with actual infrastructure
terraform refresh
```

### Issue: Bucket name conflict
Bucket names are globally unique. The random suffix should prevent this, but if it occurs:
```bash
# Destroy and redeploy to get new random suffix
terraform destroy
terraform apply
```

## Best Practices

1. **Always run `terraform plan`** before `apply`
2. **Use version control** for `.tf` files (not state files)
3. **Use variables** instead of hardcoded values
4. **Add comments** to complex configurations
5. **Use modules** for reusable components
6. **Enable remote state** for team collaboration
7. **Use workspaces** for managing multiple environments

## Learn More

- [Terraform Documentation](https://www.terraform.io/docs)
- [AWS Provider Documentation](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Terraform Best Practices](https://www.terraform-best-practices.com/)

## Comparison with Other Tools

| Feature | Terraform | CDK | CloudFormation |
|---------|-----------|-----|----------------|
| Language | HCL | TypeScript/Python/Java | YAML/JSON |
| State | Explicit state file | CloudFormation | CloudFormation |
| Scope | Multi-cloud | AWS-focused | AWS only |
| Learning Curve | Medium | Medium-High | Low-Medium |

## Next Steps

- Try the [AWS CDK](../cdk/README.md) implementation
- Try the [CloudFormation](../cloudformation/README.md) implementation
- Compare outputs using `../scripts/verify-resources.sh`
- Set up [GitHub Actions](../docs/04-github-actions.md) for CI/CD
