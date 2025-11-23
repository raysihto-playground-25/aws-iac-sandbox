# Deployment and Verification Guide

This guide covers how to deploy, verify, and destroy infrastructure using each IaC tool.

## Overview

Each implementation creates the same AWS infrastructure:
- **S3 Bucket** with versioning, encryption, and public access blocking
- Unique name using random suffix to avoid conflicts

## General Workflow

For each tool, the workflow is:
1. **Initialize** - Set up the tool (download dependencies, providers, etc.)
2. **Plan/Preview** - See what changes will be made
3. **Deploy** - Create the infrastructure
4. **Verify** - Confirm resources were created correctly
5. **Destroy** - Clean up resources when done

## Terraform Deployment

### Navigate to Terraform Directory
```bash
cd terraform
```

### Initialize Terraform
```bash
terraform init
```

This downloads the AWS provider and sets up the backend.

### Preview Changes
```bash
terraform plan
```

Review the planned changes. You should see it will create:
- 1 S3 bucket
- Associated bucket configurations

### Deploy
```bash
terraform apply
```

Type `yes` when prompted, or use auto-approve:
```bash
terraform apply -auto-approve
```

Or use the provided script:
```bash
./deploy.sh
```

### View Outputs
```bash
terraform output
```

Example output:
```
bucket_arn = "arn:aws:s3:::iac-learning-bucket-abc123"
bucket_name = "iac-learning-bucket-abc123"
```

### Verify Deployment
```bash
# Check bucket exists
aws s3 ls | grep iac-learning

# Get bucket details
aws s3api get-bucket-versioning --bucket $(terraform output -raw bucket_name)
aws s3api get-bucket-encryption --bucket $(terraform output -raw bucket_name)
```

### Destroy
```bash
terraform destroy
```

Type `yes` when prompted, or:
```bash
terraform destroy -auto-approve
```

Or use the provided script:
```bash
./destroy.sh
```

## AWS CDK Deployment

### Navigate to CDK Directory
```bash
cd cdk
```

### Install Dependencies
```bash
npm install
```

### Bootstrap (One-time, if not done already)
```bash
cdk bootstrap
```

### Preview Changes
```bash
cdk diff
```

### Deploy
```bash
cdk deploy
```

Confirm when prompted, or use:
```bash
cdk deploy --require-approval never
```

Or use the provided script:
```bash
./deploy.sh
```

### View Outputs
CDK outputs are shown after deployment. You can also check:
```bash
aws cloudformation describe-stacks --stack-name CdkStack --query 'Stacks[0].Outputs'
```

### Verify Deployment
```bash
# List stacks
aws cloudformation list-stacks --stack-status-filter CREATE_COMPLETE

# Get stack resources
aws cloudformation describe-stack-resources --stack-name CdkStack

# Verify bucket
aws s3 ls | grep iac-learning
```

### Destroy
```bash
cdk destroy
```

Or use the provided script:
```bash
./destroy.sh
```

## CloudFormation Deployment

### Navigate to CloudFormation Directory
```bash
cd cloudformation
```

### Validate Template
```bash
aws cloudformation validate-template --template-body file://template.yaml
```

### Preview Changes (Create Change Set)
```bash
aws cloudformation create-change-set \
  --stack-name iac-learning-stack \
  --template-body file://template.yaml \
  --change-set-name preview-changes

# View change set
aws cloudformation describe-change-set \
  --stack-name iac-learning-stack \
  --change-set-name preview-changes
```

### Deploy
```bash
aws cloudformation create-stack \
  --stack-name iac-learning-stack \
  --template-body file://template.yaml

# Wait for completion
aws cloudformation wait stack-create-complete --stack-name iac-learning-stack
```

Or use the provided script:
```bash
./deploy.sh
```

### View Outputs
```bash
aws cloudformation describe-stacks \
  --stack-name iac-learning-stack \
  --query 'Stacks[0].Outputs'
```

### Verify Deployment
```bash
# Check stack status
aws cloudformation describe-stacks --stack-name iac-learning-stack

# List stack resources
aws cloudformation list-stack-resources --stack-name iac-learning-stack

# Verify bucket
aws s3 ls | grep iac-learning
```

### Destroy
```bash
aws cloudformation delete-stack --stack-name iac-learning-stack

# Wait for deletion
aws cloudformation wait stack-delete-complete --stack-name iac-learning-stack
```

Or use the provided script:
```bash
./destroy.sh
```

## Verification Script

Use the provided verification script to compare all implementations:

```bash
cd /path/to/aws-iac-sandbox
./scripts/verify-resources.sh
```

This script:
1. Checks which implementations are deployed
2. Verifies S3 bucket configurations match
3. Reports any discrepancies
4. Shows resource details for comparison

### Manual Verification Steps

#### 1. Check Bucket Exists
```bash
aws s3 ls | grep iac-learning
```

#### 2. Verify Versioning
```bash
aws s3api get-bucket-versioning --bucket <bucket-name>
```

Expected output:
```json
{
    "Status": "Enabled"
}
```

#### 3. Verify Encryption
```bash
aws s3api get-bucket-encryption --bucket <bucket-name>
```

Expected output:
```json
{
    "ServerSideEncryptionConfiguration": {
        "Rules": [
            {
                "ApplyServerSideEncryptionByDefault": {
                    "SSEAlgorithm": "AES256"
                }
            }
        ]
    }
}
```

#### 4. Verify Public Access Block
```bash
aws s3api get-public-access-block --bucket <bucket-name>
```

Expected output:
```json
{
    "PublicAccessBlockConfiguration": {
        "BlockPublicAcls": true,
        "IgnorePublicAcls": true,
        "BlockPublicPolicy": true,
        "RestrictPublicBuckets": true
    }
}
```

#### 5. List Bucket Tags
```bash
aws s3api get-bucket-tagging --bucket <bucket-name>
```

Expected tags include:
- `Environment: learning`
- `ManagedBy: <tool-name>`

## Comparing All Three Implementations

Deploy all three implementations simultaneously to compare:

```bash
# Deploy Terraform
cd terraform && ./deploy.sh && cd ..

# Deploy CDK
cd cdk && ./deploy.sh && cd ..

# Deploy CloudFormation
cd cloudformation && ./deploy.sh && cd ..

# Run verification
./scripts/verify-resources.sh
```

All three should create buckets with identical configurations (except names).

## Common Issues and Solutions

### Issue: Bucket name already exists
**Solution**: Bucket names are globally unique. The random suffix should prevent this, but if it occurs, destroy and redeploy.

### Issue: Access Denied
**Solution**: 
- Verify AWS credentials: `aws sts get-caller-identity`
- Check IAM permissions for S3
- Ensure you're in the correct AWS region

### Issue: Terraform state locked
**Solution**: 
```bash
# If deployment was interrupted
terraform force-unlock <LOCK_ID>
```

### Issue: CDK bootstrap not done
**Solution**:
```bash
cdk bootstrap aws://ACCOUNT-ID/REGION
```

### Issue: CloudFormation stack stuck in UPDATE_ROLLBACK_FAILED
**Solution**:
```bash
# Continue rollback
aws cloudformation continue-update-rollback --stack-name iac-learning-stack

# Or delete and recreate
aws cloudformation delete-stack --stack-name iac-learning-stack
```

### Issue: Can't delete bucket - not empty
**Solution**:
```bash
# Empty bucket first
aws s3 rm s3://<bucket-name> --recursive

# Delete versioned objects if versioning was enabled
aws s3api delete-objects --bucket <bucket-name> \
  --delete "$(aws s3api list-object-versions --bucket <bucket-name> \
  --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' --output json)"

# Then destroy infrastructure
```

## State Management

### Terraform State
- Stored locally in `terraform.tfstate` by default
- Contains current infrastructure state
- **Never commit to version control** (in .gitignore)
- For team collaboration, use remote backends (S3, Terraform Cloud)

### CDK State
- Managed by CloudFormation
- Stored in AWS CloudFormation service
- View in AWS Console or via CLI

### CloudFormation State
- Managed by CloudFormation service
- View stacks: `aws cloudformation list-stacks`
- View resources: `aws cloudformation describe-stack-resources --stack-name <name>`

## Cost Monitoring

Monitor your AWS costs:

```bash
# Check current month's costs
aws ce get-cost-and-usage \
  --time-period Start=$(date -d "$(date +%Y-%m-01)" +%Y-%m-%d),End=$(date +%Y-%m-%d) \
  --granularity MONTHLY \
  --metrics BlendedCost
```

S3 buckets have no creation cost, only storage and request costs (covered by free tier for learning).

## Next Steps

- Try deploying with different tools to see the differences
- Explore the tool-specific READMEs:
  - [Terraform README](../terraform/README.md)
  - [CDK README](../cdk/README.md)
  - [CloudFormation README](../cloudformation/README.md)
- Set up [GitHub Actions](04-github-actions.md) for automated deployments
