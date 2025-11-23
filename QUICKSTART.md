# Quick Start Guide

This is a condensed quick start for experienced developers. For detailed instructions, see the documentation in the `docs/` directory.

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

#### Terraform (5 minutes)

```bash
cd terraform
terraform init
terraform plan
terraform apply -auto-approve
# Note the bucket name from output
terraform destroy -auto-approve
cd ..
```

#### AWS CDK (5 minutes)

```bash
cd cdk
npm install
cdk bootstrap  # One-time per account/region
cdk synth
cdk deploy --require-approval never
# Note the bucket name from output
cdk destroy --force
cd ..
```

#### CloudFormation (5 minutes)

```bash
cd cloudformation
aws cloudformation create-stack \
  --stack-name IacLearningCfnStack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM

aws cloudformation wait stack-create-complete \
  --stack-name IacLearningCfnStack

# View outputs
aws cloudformation describe-stacks \
  --stack-name IacLearningCfnStack \
  --query 'Stacks[0].Outputs'

# Destroy
aws cloudformation delete-stack --stack-name IacLearningCfnStack
cd ..
```

### 4. Compare All Three

```bash
# Deploy all three
cd terraform && ./deploy.sh && cd ..
cd cdk && ./deploy.sh && cd ..
cd cloudformation && ./deploy.sh && cd ..

# Run verification
./scripts/verify-resources.sh

# Destroy all three
cd terraform && ./destroy.sh && cd ..
cd cdk && ./destroy.sh && cd ..
cd cloudformation && ./destroy.sh && cd ..
```

## What You Just Created

Each implementation creates an S3 bucket with:
- ✅ Versioning enabled
- ✅ Server-side encryption (AES256)
- ✅ Public access blocked
- ✅ Proper tagging

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
├── terraform/         # Terraform implementation
├── cdk/              # AWS CDK implementation
├── cloudformation/   # CloudFormation implementation
├── scripts/          # Utility scripts
└── .github/workflows/ # CI/CD workflows
```

Happy learning! 🚀
