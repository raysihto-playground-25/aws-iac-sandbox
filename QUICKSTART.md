# Quick Start Guide

This is a condensed quick start for experienced developers. For detailed instructions, see the documentation in the `docs/` directory.

## Overview

This repository includes **3 scenarios** implemented with **3 IaC tools each**:

1. **S3 Bucket** - Storage with versioning and encryption
2. **DynamoDB Table** - NoSQL database with on-demand billing  
3. **Lambda + API Gateway** - Serverless REST API

## Prerequisites Checklist

- [ ] AWS account created
- [ ] AWS CLI installed and configured
- [ ] Terraform installed (>= 1.0)
- [ ] Node.js and npm installed (>= v18)
- [ ] AWS CDK CLI installed (`npm install -g aws-cdk`)

## 5-Minute Setup

### 1. Configure AWS (if not already done)

```bash
# Install AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

# Configure credentials
aws configure
# Enter: Access Key ID, Secret Access Key, Region (us-east-1), Output (json)

# Verify
aws sts get-caller-identity
```

### 2. Clone Repository

```bash
git clone https://github.com/raysihto-playground-25/aws-iac-sandbox.git
cd aws-iac-sandbox
```

### 3. Try Each Implementation

Navigate to a scenario directory:
```bash
cd scenarios/01-s3-bucket  # or 02-dynamodb-table or 03-lambda-api
```

#### Terraform (5 minutes)

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
# Note the outputs
terraform destroy -auto-approve
cd ..
```

#### AWS CDK (5 minutes)

```bash
cd cdk
npm install
cdk synth
cdk deploy --require-approval never
# Note the outputs
cdk destroy --force
cd ..
```

#### CloudFormation (5 minutes)

```bash
cd cloudformation
aws cloudformation create-stack \
  --stack-name IacLearningStack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM

aws cloudformation wait stack-create-complete \
  --stack-name IacLearningStack

# View outputs
aws cloudformation describe-stacks \
  --stack-name IacLearningStack \
  --query 'Stacks[0].Outputs'

# Destroy
aws cloudformation delete-stack --stack-name IacLearningStack
cd ..
```

### 4. Compare All Three Tools in One Scenario

```bash
cd scenarios/01-s3-bucket  # Start with S3

# Deploy all three
cd terraform && terraform init && terraform apply -auto-approve && cd ..
cd cdk && npm install && cdk deploy --require-approval never && cd ..
cd cloudformation && aws cloudformation create-stack --stack-name S3Stack --template-body file://template.yaml --capabilities CAPABILITY_IAM && cd ..

# Destroy all three  
cd terraform && terraform destroy -auto-approve && cd ..
cd cdk && cdk destroy --force && cd ..
cd cloudformation && aws cloudformation delete-stack --stack-name S3Stack && cd ..
```

## What Each Scenario Creates

### Scenario 01: S3 Bucket
- S3 bucket with versioning, encryption, public access blocking
- **Use for:** Static websites, data storage
- **Free tier:** ✅ 5GB storage

### Scenario 02: DynamoDB Table  
- DynamoDB table with partition/sort keys, point-in-time recovery
- **Use for:** User sessions, IoT data, mobile backends
- **Free tier:** ✅ 25GB storage, 25 WCU/RCU

### Scenario 03: Lambda + API Gateway
- Lambda function (Python), HTTP API Gateway, IAM roles, CloudWatch logs
- **Use for:** REST APIs, serverless backends, webhooks
- **Free tier:** ✅ 1M requests/month

All scenarios stay within AWS Free Tier limits!

## Key Differences Between Tools

| Aspect | Terraform | CDK | CloudFormation |
|--------|-----------|-----|----------------|
| **Language** | HCL (declarative) | TypeScript (imperative) | YAML (declarative) |
| **State** | Local file | CloudFormation | CloudFormation |
| **Setup** | `terraform init` | `npm install`, `cdk bootstrap` | None (built-in) |
| **Deploy** | `terraform apply` | `cdk deploy` | `aws cloudformation create-stack` |
| **Destroy** | `terraform destroy` | `cdk destroy` | `aws cloudformation delete-stack` |
| **Preview** | `terraform plan` | `cdk diff` | Change sets |
| **Multi-cloud** | ✅ Yes | ❌ AWS only | ❌ AWS only |
| **Type Safety** | ❌ No | ✅ Yes (TypeScript) | ❌ No |
| **Learning Curve** | Medium | Medium-High | Low-Medium |

## Next Steps

1. **Read the docs**: Start with `docs/01-aws-setup.md`
2. **Experiment**: Modify templates to add more resources
3. **Set up CI/CD**: Configure GitHub Actions (see `docs/04-github-actions.md`)
4. **Try more scenarios**: Add Lambda, DynamoDB, etc.

## Common Issues

**"Access Denied"** → Check IAM permissions (need S3, CloudFormation, Lambda, IAM access)

**"Bucket already exists"** → Bucket names are globally unique, destroy and redeploy

**"Terraform not initialized"** → Run `terraform init` first

**"CDK not bootstrapped"** → Run `cdk bootstrap` once per account/region

**Can't delete bucket** → Empty it first: `aws s3 rm s3://bucket-name --recursive`

## Cost

All resources in this repo are **FREE** under AWS Free Tier:
- S3 buckets have no creation cost
- Free Tier includes 5GB storage, 20K GET, 2K PUT requests/month
- Lambda function (in CloudFormation) is within free tier limits

💡 **Remember to destroy resources after learning to avoid any potential charges!**

## Help

- 📖 Full docs: `docs/` directory
- 🐛 Issues: GitHub Issues
- 💬 Questions: Open a discussion

## File Structure Quick Reference

```
aws-iac-sandbox/
├── docs/              # Detailed documentation
├── scenarios/         # Infrastructure scenarios
│   ├── 01-s3-bucket/         # Beginner: Storage
│   ├── 02-dynamodb-table/    # Intermediate: Database
│   └── 03-lambda-api/        # Advanced: Serverless API
├── scripts/           # Utility scripts
└── .github/workflows/ # CI/CD workflows
```

Each scenario has terraform/, cdk/, and cloudformation/ subdirectories.

Happy learning! 🚀
