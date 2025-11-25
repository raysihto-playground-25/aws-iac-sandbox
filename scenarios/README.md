# AWS IaC Scenarios

This directory contains multiple AWS infrastructure scenarios, each implemented using Terraform, AWS CDK, and CloudFormation.

## Available Scenarios

### 01 - S3 Bucket with Versioning
**Path:** `01-s3-bucket/`

A simple S3 bucket with versioning, encryption, and public access blocking.

**Resources:**
- S3 bucket with versioning enabled
- Server-side encryption (AES256)
- Public access block configuration

**Use Cases:**
- Static website hosting
- Application data storage
- Backup and archival
- Data lake storage

**Free Tier:** ✅ 5GB storage, 20K GET, 2K PUT requests/month

---

### 02 - DynamoDB Table
**Path:** `02-dynamodb-table/`

A DynamoDB NoSQL table with on-demand billing and point-in-time recovery.

**Resources:**
- DynamoDB table with partition key and sort key
- On-demand billing mode
- Point-in-time recovery enabled
- Server-side encryption

**Use Cases:**
- User session storage
- IoT data storage
- Mobile app backends
- Real-time data processing
- Metadata and catalog storage

**Free Tier:** ✅ 25GB storage, 25 WCU, 25 RCU

---

### 03 - Lambda Function with API Gateway
**Path:** `03-lambda-api/`

A serverless API with Lambda function and HTTP API Gateway.

**Resources:**
- Lambda function (Python runtime)
- HTTP API Gateway (v2)
- IAM role for Lambda execution
- CloudWatch log group

**Use Cases:**
- REST API endpoints
- Microservices backends
- Event-driven processing
- Data transformation
- Webhooks and integrations

**Free Tier:** ✅ 1M requests, 400K GB-seconds compute/month

---

## How to Use

Each scenario has the same structure:

```
scenarios/XX-scenario-name/
├── terraform/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── cdk/
│   ├── bin/
│   ├── lib/
│   ├── package.json
│   └── README.md
└── cloudformation/
    ├── template.yaml
    └── README.md
```

### Deploy a Scenario

1. Navigate to a scenario directory:
   ```bash
   cd scenarios/01-s3-bucket
   ```

2. Choose a tool and deploy:
   ```bash
   # Terraform
   cd terraform && terraform init && terraform apply
   
   # CDK
   cd cdk && npm install && cdk deploy
   
   # CloudFormation
   cd cloudformation && aws cloudformation create-stack ...
   ```

### Compare Tools

Deploy the same scenario with all three tools to compare:

```bash
cd scenarios/01-s3-bucket

# Deploy with all tools
cd terraform && terraform apply && cd ..
cd cdk && npm install && cdk deploy && cd ..
cd cloudformation && ./deploy.sh && cd ..
```

## Scenario Selection Guide

| Scenario | Complexity | Services | Best For Learning |
|----------|------------|----------|-------------------|
| 01 - S3 Bucket | ⭐ Easy | 1 | Tool basics, state management |
| 02 - DynamoDB | ⭐⭐ Medium | 1 | NoSQL databases, key design |
| 03 - Lambda API | ⭐⭐⭐ Advanced | 3+ | Serverless, integrations |

## Next Steps

1. Start with scenario 01 to learn IaC tool basics
2. Progress to scenario 02 to understand database infrastructure
3. Try scenario 03 to learn serverless architectures
4. Compare implementations across tools for each scenario
5. Mix and match: create your own scenarios combining these patterns

## Adding Your Own Scenarios

To add a new scenario:

1. Create directory: `scenarios/04-your-scenario/`
2. Create subdirectories: `terraform/`, `cdk/`, `cloudformation/`
3. Implement the same infrastructure in all three tools
4. Add README.md with description and use cases
5. Update this file with the new scenario

Happy learning! 🚀
