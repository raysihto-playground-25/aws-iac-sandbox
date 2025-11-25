# Scenario 02: DynamoDB Table

**Complexity:** ⭐⭐ Intermediate  
**Services:** Amazon DynamoDB  
**Free Tier:** ✅ 25GB storage, 25 WCU, 25 RCU

## Overview

This scenario demonstrates how to create a DynamoDB table with on-demand billing, point-in-time recovery, and TTL using three different IaC tools.

## Resources Created

- **DynamoDB Table** with:
  - Partition key (PK) and sort key (SK)
  - On-demand billing mode (pay-per-request)
  - Point-in-time recovery enabled
  - Server-side encryption
  - Time-to-live (TTL) attribute
  - Unique naming using random suffix

## Use Cases

- User session storage
- IoT sensor data storage
- Mobile application backends
- Real-time data processing
- Product catalogs and metadata
- Gaming leaderboards
- Shopping carts

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
terraform output  # View table name
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
  --stack-name DynamoDBLearningStack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM

aws cloudformation wait stack-create-complete \
  --stack-name DynamoDBLearningStack

aws cloudformation delete-stack --stack-name DynamoDBLearningStack
```

## Learning Objectives

This scenario teaches:

1. **NoSQL database concepts** - Partition keys, sort keys, attribute types
2. **Billing modes** - On-demand vs provisioned capacity
3. **Data protection** - Point-in-time recovery, encryption
4. **TTL configuration** - Automatic item expiration
5. **Advanced IaC patterns** - Database resources, key design

## Verification

After deploying, verify the table:

```bash
# Get table name (from outputs)
TABLE_NAME="your-table-name"

# Describe table
aws dynamodb describe-table --table-name $TABLE_NAME

# Check point-in-time recovery
aws dynamodb describe-continuous-backups --table-name $TABLE_NAME

# Test with sample data
aws dynamodb put-item \
  --table-name $TABLE_NAME \
  --item '{"PK": {"S": "USER#123"}, "SK": {"S": "PROFILE"}, "Name": {"S": "Test User"}}'

# Query the item
aws dynamodb get-item \
  --table-name $TABLE_NAME \
  --key '{"PK": {"S": "USER#123"}, "SK": {"S": "PROFILE"}}'

# Clean up test data
aws dynamodb delete-item \
  --table-name $TABLE_NAME \
  --key '{"PK": {"S": "USER#123"}, "SK": {"S": "PROFILE"}}'
```

## Key Design Pattern

This table uses a single-table design pattern:

- **PK (Partition Key):** Entity type and ID (e.g., `USER#123`, `ORDER#456`)
- **SK (Sort Key):** Entity attribute or relationship (e.g., `PROFILE`, `ADDRESS`, `ORDER#789`)
- **ExpiresAt:** TTL attribute (Unix timestamp)

Example data model:
```
PK             SK              Attributes
USER#123       PROFILE         Name, Email, CreatedAt
USER#123       ADDRESS#1       Street, City, State, Zip
ORDER#456      METADATA        Status, Total, Date
ORDER#456      ITEM#1          ProductID, Quantity, Price
```

## Next Steps

Once comfortable with this scenario:
1. Try deploying with all three tools to compare syntax
2. Experiment with adding Global Secondary Indexes (GSI)
3. Test different key patterns and queries
4. Move to [Scenario 03 - Lambda API](../03-lambda-api/) for serverless computing
5. Review the tool-specific READMEs in each subdirectory

## Cost

This scenario uses DynamoDB with on-demand billing. Within the free tier:
- First 25GB of storage: FREE
- First 25 Write Capacity Units (WCU): FREE
- First 25 Read Capacity Units (RCU): FREE

On-demand billing charges per request beyond the free tier but is very cost-effective for learning and low-traffic applications.

Remember to destroy resources after learning to avoid any charges.
