# GitHub Actions CI/CD Setup

This guide explains how to set up automated infrastructure deployments using GitHub Actions.

## Overview

GitHub Actions workflows are provided for:
- **Terraform** - Plan on PR, apply on merge to main
- **AWS CDK** - Synthesize on PR, deploy on merge to main  
- **CloudFormation** - Validate on PR, deploy on merge to main

## Prerequisites

1. GitHub repository with this code
2. AWS account with configured IAM user
3. Understanding of GitHub Actions basics

## Setting Up AWS Credentials in GitHub

### Method 1: Using GitHub Secrets (Access Keys)

⚠️ **Note**: This method stores long-lived credentials. For production, use OIDC (Method 2).

1. **Create AWS Access Keys** (if not already done)
   - Follow [AWS Setup Guide](01-aws-setup.md)
   - Save Access Key ID and Secret Access Key

2. **Add Secrets to GitHub Repository**
   - Go to your repository on GitHub
   - Click **Settings** → **Secrets and variables** → **Actions**
   - Click **New repository secret**
   - Add the following secrets:

   | Secret Name | Value |
   |-------------|-------|
   | `AWS_ACCESS_KEY_ID` | Your AWS Access Key ID |
   | `AWS_SECRET_ACCESS_KEY` | Your AWS Secret Access Key |
   | `AWS_REGION` | Your AWS region (e.g., `us-east-1`) |

3. **Verify Secrets**
   - Secrets should show in the list (values are hidden)
   - Names must match exactly as shown above

### Method 2: Using OIDC (Recommended for Production)

OIDC allows GitHub Actions to assume an IAM role without storing credentials.

#### Create IAM Role for GitHub Actions

1. **Create Trust Policy**

Save as `github-actions-trust-policy.json`:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Federated": "arn:aws:iam::YOUR_ACCOUNT_ID:oidc-provider/token.actions.githubusercontent.com"
      },
      "Action": "sts:AssumeRoleWithWebIdentity",
      "Condition": {
        "StringEquals": {
          "token.actions.githubusercontent.com:aud": "sts.amazonaws.com"
        },
        "StringLike": {
          "token.actions.githubusercontent.com:sub": "repo:YOUR_GITHUB_ORG/aws-iac-sandbox:*"
        }
      }
    }
  ]
}
```

Replace:
- `YOUR_ACCOUNT_ID` with your AWS account ID
- `YOUR_GITHUB_ORG` with your GitHub username or org

2. **Create OIDC Provider** (one-time setup per account)

```bash
aws iam create-open-id-connect-provider \
  --url https://token.actions.githubusercontent.com \
  --client-id-list sts.amazonaws.com \
  --thumbprint-list 6938fd4d98bab03faadb97b34396831e3780aea1
```

3. **Create IAM Role**

```bash
aws iam create-role \
  --role-name github-actions-iac-deployer \
  --assume-role-policy-document file://github-actions-trust-policy.json
```

4. **Attach Policies**

```bash
aws iam attach-role-policy \
  --role-name github-actions-iac-deployer \
  --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
```

5. **Add Role ARN to GitHub Secrets**

```bash
# Get role ARN
aws iam get-role --role-name github-actions-iac-deployer --query 'Role.Arn'
```

Add secret:
- Name: `AWS_ROLE_ARN`
- Value: `arn:aws:iam::ACCOUNT_ID:role/github-actions-iac-deployer`

6. **Update Workflows** to use OIDC (see workflow files)

## Workflow Details

### Terraform Workflow

**File**: `.github/workflows/terraform.yml`

**Triggers**:
- Pull requests to `main` branch (plan only)
- Push to `main` branch (plan and apply)

**Steps**:
1. Checkout code
2. Configure AWS credentials
3. Setup Terraform
4. Terraform init
5. Terraform plan (always)
6. Terraform apply (only on push to main)

**Usage**:
- Create PR → Workflow runs `terraform plan` as a check
- Merge PR → Workflow runs `terraform apply` to deploy

### CDK Workflow

**File**: `.github/workflows/cdk.yml`

**Triggers**:
- Pull requests to `main` branch (synth only)
- Push to `main` branch (synth and deploy)

**Steps**:
1. Checkout code
2. Configure AWS credentials
3. Setup Node.js
4. Install dependencies
5. CDK synth (always)
6. CDK deploy (only on push to main)

**Usage**:
- Create PR → Workflow runs `cdk synth` to validate
- Merge PR → Workflow runs `cdk deploy` to deploy

### CloudFormation Workflow

**File**: `.github/workflows/cloudformation.yml`

**Triggers**:
- Pull requests to `main` branch (validate only)
- Push to `main` branch (validate and deploy)

**Steps**:
1. Checkout code
2. Configure AWS credentials
3. Validate template (always)
4. Deploy stack (only on push to main)

**Usage**:
- Create PR → Workflow validates template
- Merge PR → Workflow deploys stack

## Environment Protection (Optional)

Add approval requirements for production deployments:

1. **Create Environment**
   - Go to **Settings** → **Environments**
   - Click **New environment**
   - Name: `production`
   - Add protection rules:
     - Required reviewers: Add yourself or team members
     - Wait timer: Optional delay before deployment

2. **Update Workflows**

Add environment to deploy step:
```yaml
- name: Deploy
  if: github.ref == 'refs/heads/main'
  environment: production
  run: terraform apply -auto-approve
```

Now deployments to `main` require manual approval.

## Workflow Customization

### Deploy on Specific Paths Only

Only run workflow when specific files change:

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'terraform/**'
      - '.github/workflows/terraform.yml'
  pull_request:
    paths:
      - 'terraform/**'
```

### Deploy to Multiple Environments

Add matrix strategy:

```yaml
strategy:
  matrix:
    environment: [dev, staging, prod]
    
steps:
  - name: Deploy to ${{ matrix.environment }}
    run: terraform apply -var="environment=${{ matrix.environment }}"
```

### Add Slack Notifications

```yaml
- name: Notify Slack
  if: always()
  uses: 8398a7/action-slack@v3
  with:
    status: ${{ job.status }}
    webhook_url: ${{ secrets.SLACK_WEBHOOK }}
```

## Monitoring Workflows

### View Workflow Runs

1. Go to **Actions** tab in your repository
2. Select a workflow from the left sidebar
3. Click on a specific run to see details

### Debug Failed Workflows

1. Click on failed workflow run
2. Click on failed job
3. Expand failed step to see error logs
4. Common issues:
   - Missing secrets
   - Incorrect AWS permissions
   - Terraform state conflicts
   - Syntax errors in templates

### Enable Debug Logging

Add secrets for verbose logging:
- `ACTIONS_STEP_DEBUG` = `true`
- `ACTIONS_RUNNER_DEBUG` = `true`

## Best Practices

### 1. Use Separate AWS Accounts
- Development → Dev account
- Production → Prod account
- Use different secrets/roles per environment

### 2. Require PR Reviews
Settings → Branches → Add rule:
- Require pull request reviews before merging
- Require status checks (workflows) to pass

### 3. Lock Production Branch
- Protect `main` branch
- Require reviews
- Require status checks

### 4. Use Terraform Remote State
Store state in S3 instead of locally:

```hcl
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "iac-learning/terraform.tfstate"
    region = "us-east-1"
  }
}
```

### 5. Manual Approval for Destroy
Never auto-destroy in workflows. Add manual confirmation:

```yaml
- name: Confirm Destroy
  if: github.event_name == 'workflow_dispatch'
  run: |
    echo "Destroy action requires manual confirmation"
    # Add confirmation logic
```

### 6. Cost Alerts
Set up AWS Budget alerts:

```bash
aws budgets create-budget \
  --account-id YOUR_ACCOUNT_ID \
  --budget file://budget.json \
  --notifications-with-subscribers file://notifications.json
```

## Security Considerations

### Secrets Management
- ✅ Use GitHub encrypted secrets
- ✅ Rotate AWS keys regularly (every 90 days)
- ✅ Use OIDC instead of long-lived keys
- ❌ Never log secrets in workflow output
- ❌ Never commit secrets to repository

### Permissions
- Use least privilege IAM policies
- Separate read/write permissions
- Use different credentials per environment
- Audit access with CloudTrail

### State Files
- Store Terraform state in encrypted S3 bucket
- Enable versioning on state bucket
- Enable state locking with DynamoDB
- Never commit state files to Git

## Workflow Dependencies

Require workflows to pass before merge:

**Settings** → **Branches** → **Branch protection rules**:
- Require status checks before merging
- Select workflows:
  - `Terraform CI`
  - `CDK CI`
  - `CloudFormation CI`

## Example: Full Deployment Pipeline

1. **Developer creates feature branch**
   ```bash
   git checkout -b feature/add-encryption
   ```

2. **Make changes to infrastructure**
   ```bash
   # Edit terraform/main.tf
   git add terraform/
   git commit -m "Add bucket encryption"
   git push origin feature/add-encryption
   ```

3. **Create Pull Request**
   - Workflows run automatically
   - Terraform plan shows proposed changes
   - Review changes in PR

4. **Review and Merge**
   - Team reviews PR and plan
   - Approve and merge to `main`

5. **Automatic Deployment**
   - Workflow runs on `main` branch
   - Infrastructure deployed to AWS
   - Check workflow logs for confirmation

## Troubleshooting

### Workflow not triggering
- Check branch name matches trigger
- Verify paths filter if configured
- Check workflow file syntax (YAML valid)

### AWS authentication fails
- Verify secrets are set correctly
- Check IAM permissions
- Ensure region is correct
- Test credentials locally first

### State lock errors (Terraform)
- Check if previous workflow is still running
- Manually unlock if needed: `terraform force-unlock <ID>`
- Use S3 + DynamoDB for state locking in team settings

### CDK bootstrap required
- Run bootstrap manually first
- Or add bootstrap step to workflow (one-time)

## Additional Resources

- [GitHub Actions Documentation](https://docs.github.com/actions)
- [AWS Credentials for GitHub Actions](https://github.com/aws-actions/configure-aws-credentials)
- [Terraform GitHub Actions](https://learn.hashicorp.com/tutorials/terraform/github-actions)
- [CDK Deployment Guide](https://docs.aws.amazon.com/cdk/latest/guide/home.html)

## Next Steps

After setting up CI/CD:
1. Test workflows by creating a PR
2. Monitor workflow runs
3. Set up notifications for failures
4. Configure environment protection for production
