# AWS CloudFormation Implementation

This directory contains the AWS CloudFormation implementation using YAML templates.

## Overview

AWS CloudFormation is AWS's native Infrastructure as Code service. It uses declarative templates in YAML or JSON format to define AWS resources.

## What's Created

- **S3 Bucket** with a unique name (using Lambda-generated random suffix)
- **Versioning** enabled for object version history
- **Server-Side Encryption** using AES256
- **Public Access Block** to prevent accidental public exposure
- **Lambda Function** (helper) to generate unique bucket names

## Prerequisites

- AWS CLI configured with valid credentials
- Appropriate IAM permissions for S3, CloudFormation, Lambda, and IAM

See [Local Environment Setup](../docs/02-local-environment.md) for setup instructions.

## Files

- `template.yaml` - CloudFormation template defining resources
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
# Validate template
aws cloudformation validate-template --template-body file://template.yaml

# Create stack
aws cloudformation create-stack \
  --stack-name IacLearningCfnStack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM

# Wait for creation
aws cloudformation wait stack-create-complete --stack-name IacLearningCfnStack

# View outputs
aws cloudformation describe-stacks \
  --stack-name IacLearningCfnStack \
  --query 'Stacks[0].Outputs'

# Delete stack
aws cloudformation delete-stack --stack-name IacLearningCfnStack
```

## Detailed Usage

### Validate Template

Check template syntax before deployment:

```bash
aws cloudformation validate-template --template-body file://template.yaml
```

### Preview Changes (Change Set)

See what will be created/modified without actually making changes:

```bash
# Create change set
aws cloudformation create-change-set \
  --stack-name IacLearningCfnStack \
  --template-body file://template.yaml \
  --change-set-name preview-changes \
  --capabilities CAPABILITY_IAM

# View change set
aws cloudformation describe-change-set \
  --stack-name IacLearningCfnStack \
  --change-set-name preview-changes

# Execute change set (if satisfied)
aws cloudformation execute-change-set \
  --stack-name IacLearningCfnStack \
  --change-set-name preview-changes
```

### Deploy Stack

Create the stack:

```bash
aws cloudformation create-stack \
  --stack-name IacLearningCfnStack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM
```

The `CAPABILITY_IAM` capability is required because the template creates IAM roles.

### Monitor Deployment

Watch stack creation progress:

```bash
# Wait for completion
aws cloudformation wait stack-create-complete --stack-name IacLearningCfnStack

# Or watch events in real-time
aws cloudformation describe-stack-events \
  --stack-name IacLearningCfnStack \
  --max-items 10
```

### View Outputs

After deployment:

```bash
aws cloudformation describe-stacks \
  --stack-name IacLearningCfnStack \
  --query 'Stacks[0].Outputs' \
  --output table
```

Example output:
```
BucketName: iac-learning-bucket-abc12345
BucketArn: arn:aws:s3:::iac-learning-bucket-abc12345
BucketRegion: us-east-1
```

### Update Stack

Modify template and update existing stack:

```bash
aws cloudformation update-stack \
  --stack-name IacLearningCfnStack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM

# Wait for update
aws cloudformation wait stack-update-complete --stack-name IacLearningCfnStack
```

### Delete Stack

Remove all resources:

```bash
# First, empty the S3 bucket (required)
BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name IacLearningCfnStack \
  --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
  --output text)

aws s3 rm s3://$BUCKET_NAME --recursive

# Then delete stack
aws cloudformation delete-stack --stack-name IacLearningCfnStack

# Wait for deletion
aws cloudformation wait stack-delete-complete --stack-name IacLearningCfnStack
```

## Customization

### Change Stack Name

Use a different stack name:

```bash
export STACK_NAME=MyCustomStack
./deploy.sh
```

### Change Parameters

Override default parameters:

```bash
aws cloudformation create-stack \
  --stack-name IacLearningCfnStack \
  --template-body file://template.yaml \
  --parameters \
    ParameterKey=BucketPrefix,ParameterValue=my-custom-prefix \
    ParameterKey=Environment,ParameterValue=dev \
  --capabilities CAPABILITY_IAM
```

### Change Region

CloudFormation uses the AWS CLI's configured region. Override with:

```bash
aws cloudformation create-stack \
  --stack-name IacLearningCfnStack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM \
  --region us-west-2
```

## Understanding the Template

### Parameters

Define configurable values:

```yaml
Parameters:
  BucketPrefix:
    Type: String
    Default: iac-learning-bucket
    Description: Prefix for the S3 bucket name
```

### Resources

Define AWS resources:

```yaml
Resources:
  LearningBucket:
    Type: AWS::S3::Bucket
    Properties:
      BucketName: !Sub '${BucketPrefix}-${RandomSuffix.Value}'
      VersioningConfiguration:
        Status: Enabled
```

### Intrinsic Functions

CloudFormation provides built-in functions:

- `!Ref` - Reference another resource or parameter
- `!GetAtt` - Get attribute from a resource
- `!Sub` - String substitution
- `!Join` - Join strings

Example:
```yaml
BucketName: !Sub '${BucketPrefix}-${RandomSuffix.Value}'
```

### Outputs

Export values for use elsewhere:

```yaml
Outputs:
  BucketName:
    Description: Name of the created S3 bucket
    Value: !Ref LearningBucket
    Export:
      Name: !Sub '${AWS::StackName}-BucketName'
```

## Verification

Verify the bucket was created correctly:

```bash
# Get bucket name from stack
BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name IacLearningCfnStack \
  --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
  --output text)

# Check bucket exists
aws s3 ls | grep $BUCKET_NAME

# Verify versioning
aws s3api get-bucket-versioning --bucket $BUCKET_NAME

# Verify encryption
aws s3api get-bucket-encryption --bucket $BUCKET_NAME

# Verify public access block
aws s3api get-public-access-block --bucket $BUCKET_NAME

# Verify tags
aws s3api get-bucket-tagging --bucket $BUCKET_NAME
```

## CloudFormation CLI Commands

```bash
# List all stacks
aws cloudformation list-stacks

# Describe stack
aws cloudformation describe-stacks --stack-name IacLearningCfnStack

# List stack resources
aws cloudformation list-stack-resources --stack-name IacLearningCfnStack

# Describe specific resource
aws cloudformation describe-stack-resource \
  --stack-name IacLearningCfnStack \
  --logical-resource-id LearningBucket

# View stack events
aws cloudformation describe-stack-events --stack-name IacLearningCfnStack

# Get template
aws cloudformation get-template --stack-name IacLearningCfnStack

# Detect stack drift
aws cloudformation detect-stack-drift --stack-name IacLearningCfnStack
```

## Troubleshooting

### Issue: Stack creation failed
```bash
# View failure reason
aws cloudformation describe-stack-events \
  --stack-name IacLearningCfnStack \
  --query 'StackEvents[?ResourceStatus==`CREATE_FAILED`]'

# Delete failed stack
aws cloudformation delete-stack --stack-name IacLearningCfnStack
```

### Issue: Stack stuck in UPDATE_ROLLBACK_FAILED
```bash
# Continue rollback
aws cloudformation continue-update-rollback --stack-name IacLearningCfnStack
```

### Issue: Can't delete stack - bucket not empty
```bash
# Empty bucket first
BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name IacLearningCfnStack \
  --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
  --output text)

aws s3 rm s3://$BUCKET_NAME --recursive

# Delete all versions
aws s3api delete-objects --bucket $BUCKET_NAME \
  --delete "$(aws s3api list-object-versions --bucket $BUCKET_NAME \
  --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}')"
```

### Issue: Insufficient permissions
Ensure your IAM user has these permissions:
- `cloudformation:*`
- `s3:*`
- `lambda:*`
- `iam:CreateRole`, `iam:AttachRolePolicy`, etc.

### Issue: Template validation error
```bash
# Check YAML syntax
yamllint template.yaml

# Validate with CloudFormation
aws cloudformation validate-template --template-body file://template.yaml
```

## Stack Policies (Optional)

Protect resources from being updated or deleted:

```json
{
  "Statement": [
    {
      "Effect": "Deny",
      "Principal": "*",
      "Action": "Update:Delete",
      "Resource": "LogicalResourceId/LearningBucket"
    }
  ]
}
```

Apply:
```bash
aws cloudformation set-stack-policy \
  --stack-name IacLearningCfnStack \
  --stack-policy-body file://policy.json
```

## Drift Detection

Detect manual changes made outside CloudFormation:

```bash
# Initiate drift detection
DRIFT_ID=$(aws cloudformation detect-stack-drift \
  --stack-name IacLearningCfnStack \
  --query 'StackDriftDetectionId' \
  --output text)

# Check drift status
aws cloudformation describe-stack-drift-detection-status \
  --stack-drift-detection-id $DRIFT_ID

# View drift details
aws cloudformation describe-stack-resource-drifts \
  --stack-name IacLearningCfnStack
```

## Best Practices

1. **Always validate** templates before deployment
2. **Use change sets** to preview updates
3. **Tag resources** consistently
4. **Use parameters** for configurable values
5. **Export outputs** for cross-stack references
6. **Enable termination protection** for production stacks
7. **Use stack policies** to prevent accidental deletions
8. **Version control** templates in Git

## Advanced Features

### Cross-Stack References

Export from one stack:
```yaml
Outputs:
  BucketName:
    Export:
      Name: MyBucketName
    Value: !Ref Bucket
```

Import in another stack:
```yaml
Resources:
  MyResource:
    Properties:
      BucketName: !ImportValue MyBucketName
```

### Nested Stacks

Reference other templates:
```yaml
Resources:
  NestedStack:
    Type: AWS::CloudFormation::Stack
    Properties:
      TemplateURL: https://s3.amazonaws.com/bucket/nested-template.yaml
```

## Learn More

- [CloudFormation Documentation](https://docs.aws.amazon.com/cloudformation/)
- [Template Reference](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/template-reference.html)
- [Best Practices](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/best-practices.html)
- [Sample Templates](https://github.com/awslabs/aws-cloudformation-templates)

## Comparison with Other Tools

| Feature | CloudFormation | Terraform | CDK |
|---------|---------------|-----------|-----|
| Language | YAML/JSON | HCL | TypeScript/Python |
| Provider | AWS only | Multi-cloud | AWS-focused |
| State | AWS-managed | Explicit file | CloudFormation |
| Learning Curve | Low-Medium | Medium | Medium-High |
| IDE Support | Limited | Good | Excellent |

## Next Steps

- Try the [Terraform](../terraform/README.md) implementation
- Try the [CDK](../cdk/README.md) implementation
- Compare outputs using `../scripts/verify-resources.sh`
- Set up [GitHub Actions](../docs/04-github-actions.md) for CI/CD
