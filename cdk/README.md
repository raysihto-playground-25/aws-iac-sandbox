# AWS CDK Implementation

This directory contains the AWS CDK (Cloud Development Kit) implementation using TypeScript.

## Overview

AWS CDK is a software development framework for defining cloud infrastructure using familiar programming languages. This implementation uses TypeScript to define an S3 bucket with the same configuration as other implementations.

## What's Created

- **S3 Bucket** with a unique name (using account and region)
- **Versioning** enabled for object version history
- **Server-Side Encryption** using S3-managed keys (AES256)
- **Public Access Block** to prevent accidental public exposure
- **SSL/TLS enforcement** for all requests

## Prerequisites

- [Node.js](https://nodejs.org/) (v14 or later)
- [AWS CDK CLI](https://docs.aws.amazon.com/cdk/latest/guide/cli.html)
- AWS CLI configured with valid credentials
- Appropriate IAM permissions for S3 and CloudFormation

See [Local Environment Setup](../docs/02-local-environment.md) for installation instructions.

## Files

- `bin/cdk.ts` - CDK app entry point
- `lib/iac-learning-stack.ts` - Stack definition with S3 bucket
- `package.json` - Node.js dependencies and scripts
- `tsconfig.json` - TypeScript configuration
- `cdk.json` - CDK configuration
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
# Install dependencies (first time only)
npm install

# Bootstrap CDK (first time per account/region)
cdk bootstrap

# Synthesize CloudFormation template
npm run build
cdk synth

# Deploy infrastructure
cdk deploy

# Destroy infrastructure
cdk destroy
```

## Detailed Usage

### Install Dependencies

Install required npm packages:

```bash
npm install
```

This installs:
- `aws-cdk-lib` - CDK core library
- `constructs` - CDK constructs library
- TypeScript and type definitions

### Bootstrap CDK

One-time setup per AWS account and region:

```bash
cdk bootstrap
```

Or specify account/region explicitly:

```bash
cdk bootstrap aws://123456789012/us-east-1
```

This creates:
- S3 bucket for CDK assets
- IAM roles for CloudFormation
- ECR repository for Docker images (if needed)

### Synthesize

Convert CDK code to CloudFormation template:

```bash
npm run build  # Compile TypeScript
cdk synth      # Generate CloudFormation template
```

The template is saved in `cdk.out/IacLearningCdkStack.template.json`.

### Diff

See what changes will be made:

```bash
cdk diff
```

Useful before deploying to review changes.

### Deploy

Deploy the stack to AWS:

```bash
cdk deploy
```

Or without approval prompts:

```bash
cdk deploy --require-approval never
```

### View Outputs

After deployment, outputs are displayed. You can also view them:

```bash
# Using AWS CLI
aws cloudformation describe-stacks \
  --stack-name IacLearningCdkStack \
  --query 'Stacks[0].Outputs'

# Using CDK
cdk list
```

### Destroy

Remove all resources:

```bash
cdk destroy
```

Or without confirmation:

```bash
cdk destroy --force
```

## Customization

### Change Region

Set the `CDK_DEFAULT_REGION` environment variable:

```bash
export CDK_DEFAULT_REGION=us-west-2
cdk deploy
```

Or modify `bin/cdk.ts`:

```typescript
region: 'us-west-2'
```

### Change Stack Name

Modify the stack ID in `bin/cdk.ts`:

```typescript
new IacLearningStack(app, 'MyCustomStackName', {
  // ...
});
```

### Add More Resources

Edit `lib/iac-learning-stack.ts` and add CDK constructs:

```typescript
// Example: Add another bucket
const anotherBucket = new s3.Bucket(this, 'AnotherBucket', {
  versioned: true,
});
```

### Enable Auto-Delete

For easier cleanup during learning, enable auto-delete:

```typescript
const bucket = new s3.Bucket(this, 'LearningBucket', {
  // ...
  removalPolicy: cdk.RemovalPolicy.DESTROY,
  autoDeleteObjects: true,  // Automatically empty bucket on destroy
});
```

⚠️ **Warning**: Never use this in production!

## Understanding the Code

### Stack Structure

```typescript
export class IacLearningStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    
    // Define resources here
    const bucket = new s3.Bucket(this, 'LearningBucket', {
      // Configuration
    });
  }
}
```

### Resource Properties

```typescript
const bucket = new s3.Bucket(this, 'LearningBucket', {
  versioned: true,                              // Enable versioning
  encryption: s3.BucketEncryption.S3_MANAGED,  // AES256 encryption
  blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,  // Block public access
  enforceSSL: true,                            // Require HTTPS
});
```

### Outputs

```typescript
new cdk.CfnOutput(this, 'BucketName', {
  value: bucket.bucketName,
  description: 'Name of the created S3 bucket',
  exportName: 'IacLearningBucketName',
});
```

## Verification

Verify the bucket was created:

```bash
# Get stack outputs
aws cloudformation describe-stacks \
  --stack-name IacLearningCdkStack \
  --query 'Stacks[0].Outputs'

# List buckets
aws s3 ls | grep iac-learning

# Get bucket name from stack
BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name IacLearningCdkStack \
  --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
  --output text)

# Verify versioning
aws s3api get-bucket-versioning --bucket $BUCKET_NAME

# Verify encryption
aws s3api get-bucket-encryption --bucket $BUCKET_NAME
```

## CDK Commands

```bash
# List all stacks
cdk list

# Show CloudFormation template
cdk synth

# Compare deployed stack with current state
cdk diff

# Deploy specific stack
cdk deploy IacLearningCdkStack

# Destroy specific stack
cdk destroy IacLearningCdkStack

# View stack metadata
cdk metadata

# View CDK version
cdk --version
```

## Troubleshooting

### Issue: "CDK is not bootstrapped"
```bash
# Bootstrap your account/region
cdk bootstrap
```

### Issue: npm install fails
```bash
# Clear cache and reinstall
rm -rf node_modules package-lock.json
npm install
```

### Issue: TypeScript compilation errors
```bash
# Check TypeScript version
npx tsc --version

# Reinstall dependencies
npm install
```

### Issue: Stack already exists
```bash
# If you want to update existing stack
cdk deploy

# If you want to start fresh
cdk destroy
cdk deploy
```

### Issue: Bucket not emptying on destroy
The default configuration has `removalPolicy: RETAIN` for safety. To allow automatic cleanup:

```typescript
removalPolicy: cdk.RemovalPolicy.DESTROY,
autoDeleteObjects: true,
```

Or manually empty the bucket:
```bash
aws s3 rm s3://bucket-name --recursive
```

## Best Practices

1. **Use TypeScript** for type safety and IDE support
2. **Organize by stacks** - separate stacks for different environments
3. **Use constructs** - create reusable components
4. **Version dependencies** - specify exact versions in package.json
5. **Test constructs** - use CDK assertions for unit tests
6. **Use context** - store configuration in cdk.json context
7. **Tag resources** - use `cdk.Tags.of()` for consistent tagging

## Advanced Usage

### Multiple Environments

```typescript
// bin/cdk.ts
new IacLearningStack(app, 'IacLearningDevStack', {
  env: { account: '111111111111', region: 'us-east-1' },
});

new IacLearningStack(app, 'IacLearningProdStack', {
  env: { account: '222222222222', region: 'us-west-2' },
});
```

Deploy specific environment:
```bash
cdk deploy IacLearningDevStack
```

### Using CDK Context

Store configuration in `cdk.json`:

```json
{
  "context": {
    "bucketPrefix": "my-app",
    "environment": "development"
  }
}
```

Access in code:
```typescript
const prefix = this.node.tryGetContext('bucketPrefix');
```

### Custom Constructs

Create reusable components:

```typescript
// lib/constructs/secure-bucket.ts
export class SecureBucket extends Construct {
  public readonly bucket: s3.Bucket;
  
  constructor(scope: Construct, id: string) {
    super(scope, id);
    
    this.bucket = new s3.Bucket(this, 'Bucket', {
      versioned: true,
      encryption: s3.BucketEncryption.S3_MANAGED,
      blockPublicAccess: s3.BlockPublicAccess.BLOCK_ALL,
    });
  }
}
```

Use it:
```typescript
const secureBucket = new SecureBucket(this, 'MySecureBucket');
```

## Learn More

- [AWS CDK Documentation](https://docs.aws.amazon.com/cdk/latest/guide/home.html)
- [CDK API Reference](https://docs.aws.amazon.com/cdk/api/latest/)
- [CDK Workshop](https://cdkworkshop.com/)
- [CDK Patterns](https://cdkpatterns.com/)

## Comparison with Other Tools

| Feature | CDK | Terraform | CloudFormation |
|---------|-----|-----------|----------------|
| Language | TypeScript/Python/Java | HCL | YAML/JSON |
| State | CloudFormation | Explicit | CloudFormation |
| Testing | Unit tests possible | Limited | Limited |
| IDE Support | Excellent | Good | Limited |
| Learning Curve | Medium-High | Medium | Low-Medium |

## Next Steps

- Try the [Terraform](../terraform/README.md) implementation
- Try the [CloudFormation](../cloudformation/README.md) implementation
- Compare outputs using `../scripts/verify-resources.sh`
- Set up [GitHub Actions](../docs/04-github-actions.md) for CI/CD
