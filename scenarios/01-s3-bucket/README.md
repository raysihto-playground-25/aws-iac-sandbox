# Scenario 01: S3 Bucket with Versioning

**Complexity:** ⭐ Beginner  
**Services:** Amazon S3  
**Free Tier:** ✅ 5GB storage, 20K GET, 2K PUT requests/month

## Overview

This scenario demonstrates how to create an S3 bucket with versioning, server-side encryption, and public access blocking using three different IaC tools.

## Resources Created

- **S3 Bucket** with:
  - Versioning enabled
  - Server-side encryption (AES256)
  - Public access fully blocked
  - Unique naming using random suffix

## Use Cases

- Static website hosting
- Application data storage
- Backup and archival
- Data lake storage
- Log aggregation

## Implementations

Each subdirectory contains a complete implementation:

- **terraform/** - HashiCorp Terraform (HCL)
- **cdk/** - AWS CDK (TypeScript)
- **cloudformation/** - AWS CloudFormation (YAML)

## Quick Deploy

### Terraform
```bash
cd terraform
terraform init
terraform apply -auto-approve
terraform output  # View bucket name
terraform destroy -auto-approve
```

### AWS CDK
```bash
cd cdk
npm install
cdk deploy --require-approval never
cdk destroy --force
```

### CloudFormation
```bash
cd cloudformation
aws cloudformation create-stack \
  --stack-name S3LearningStack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM

aws cloudformation wait stack-create-complete \
  --stack-name S3LearningStack

aws cloudformation delete-stack --stack-name S3LearningStack
```

## Learning Objectives

This scenario teaches:

1. **Basic IaC concepts** - Resource definitions, parameters, outputs
2. **State management** - How each tool tracks infrastructure
3. **Resource properties** - Configuring AWS resources
4. **Naming strategies** - Ensuring unique resource names
5. **Tool syntax** - Comparing HCL vs TypeScript vs YAML

## Verification

After deploying, verify the bucket:

```bash
# Get bucket name (from outputs)
BUCKET_NAME="your-bucket-name"

# Check versioning
aws s3api get-bucket-versioning --bucket $BUCKET_NAME

# Check encryption
aws s3api get-bucket-encryption --bucket $BUCKET_NAME

# Check public access block
aws s3api get-public-access-block --bucket $BUCKET_NAME
```

## Next Steps

Once comfortable with this scenario:
1. Try deploying with all three tools to compare
2. Experiment with modifying bucket properties
3. Move to [Scenario 02 - DynamoDB](../02-dynamodb-table/) for more complexity
4. Review the tool-specific READMEs in each subdirectory

## Cost

This scenario uses only S3 buckets, which are free to create. Within the free tier:
- First 5GB of storage: FREE
- 20,000 GET requests: FREE
- 2,000 PUT requests: FREE

Remember to destroy resources after learning to avoid any charges.
