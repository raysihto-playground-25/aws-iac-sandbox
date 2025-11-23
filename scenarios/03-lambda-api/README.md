# Scenario 03: Lambda Function with API Gateway

**Complexity:** ⭐⭐⭐ Advanced  
**Services:** AWS Lambda, API Gateway, IAM, CloudWatch Logs  
**Free Tier:** ✅ 1M requests, 400K GB-seconds compute/month

## Overview

This scenario demonstrates how to create a serverless REST API using Lambda and API Gateway with three different IaC tools.

## Resources Created

- **Lambda Function** (Python 3.11)
  - Execution role with basic permissions
  - CloudWatch log group (7-day retention)
  - 30-second timeout
  - Environment variables
  
- **HTTP API Gateway (v2)**
  - GET / route
  - Lambda proxy integration
  - Auto-deploy stage
  
- **IAM Role** for Lambda execution
- **CloudWatch Log Group** for function logs

## Use Cases

- REST API endpoints
- Microservices backends
- Webhook handlers
- Data transformation APIs
- Integration endpoints
- Serverless web backends
- Event-driven processing

## Implementations

Each subdirectory contains a complete implementation:

- **terraform/** - HashiCorp Terraform (HCL) with inline Lambda code
- **cdk/** - AWS CDK (TypeScript) with Lambda code in /lambda directory
- **cloudformation/** - AWS CloudFormation (YAML) with inline Lambda code

## Quick Deploy

### Terraform
```bash
cd terraform
terraform init
terraform apply -auto-approve
terraform output  # Get API endpoint URL

# Test the API
curl $(terraform output -raw api_endpoint)

terraform destroy -auto-approve
```

### AWS CDK
```bash
cd cdk
npm install
cdk deploy --require-approval never

# Get endpoint from outputs or stack
API_URL=$(aws cloudformation describe-stacks \
  --stack-name IacLearningLambdaApiStack \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiEndpoint`].OutputValue' \
  --output text)

# Test the API
curl $API_URL

cdk destroy --force
```

### CloudFormation
```bash
cd cloudformation
aws cloudformation create-stack \
  --stack-name LambdaApiLearningStack \
  --template-body file://template.yaml \
  --capabilities CAPABILITY_IAM

aws cloudformation wait stack-create-complete \
  --stack-name LambdaApiLearningStack

# Get API endpoint
API_URL=$(aws cloudformation describe-stacks \
  --stack-name LambdaApiLearningStack \
  --query 'Stacks[0].Outputs[?OutputKey==`ApiEndpoint`].OutputValue' \
  --output text)

# Test the API
curl $API_URL

aws cloudformation delete-stack --stack-name LambdaApiLearningStack
```

## Learning Objectives

This scenario teaches:

1. **Serverless architecture** - Lambda functions, API Gateway
2. **IAM roles and permissions** - Lambda execution roles
3. **API integrations** - HTTP API with Lambda proxy integration
4. **Logging and monitoring** - CloudWatch log groups
5. **Multi-resource IaC** - Managing dependencies between resources
6. **Code deployment** - Inline vs file-based Lambda code

## API Response

The Lambda function returns a JSON response:

```json
{
  "message": "Hello from Lambda!",
  "tool": "Terraform|CDK|CloudFormation",
  "event": { ... }
}
```

## Verification

After deploying, test the API:

```bash
# Get API URL from outputs
API_URL="your-api-url"

# Test GET request
curl $API_URL

# Check Lambda logs
FUNCTION_NAME="your-function-name"
aws logs tail /aws/lambda/$FUNCTION_NAME --follow

# Invoke Lambda directly
aws lambda invoke \
  --function-name $FUNCTION_NAME \
  --payload '{"test": "data"}' \
  response.json

cat response.json
```

## Customization Ideas

Try extending this scenario:

1. **Add more routes** - POST, PUT, DELETE endpoints
2. **Add request validation** - API Gateway request validators
3. **Add authentication** - API keys, Cognito, Lambda authorizers
4. **Add CORS** - Cross-origin resource sharing
5. **Add DynamoDB** - Persist data from API calls
6. **Add S3** - Store uploaded files
7. **Add environment variables** - Configuration management

## Architecture

```
Internet
   │
   ▼
API Gateway (HTTP API)
   │
   ▼
Lambda Function (Python)
   │
   ▼
CloudWatch Logs
```

## Lambda Function Code

The Lambda function is a simple "Hello World" example:

```python
import json

def lambda_handler(event, context):
    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': json.dumps({
            'message': 'Hello from Lambda!',
            'tool': 'Your-Tool-Here',
            'event': event
        })
    }
```

## Next Steps

Once comfortable with this scenario:
1. Try deploying with all three tools to compare
2. Modify the Lambda function to add business logic
3. Add more API routes and methods
4. Integrate with scenarios 01 (S3) or 02 (DynamoDB)
5. Implement error handling and input validation
6. Review the tool-specific READMEs in each subdirectory

## Cost

This scenario uses serverless services with generous free tiers:

**Lambda:**
- First 1 million requests per month: FREE
- First 400,000 GB-seconds of compute: FREE

**API Gateway HTTP API:**
- First 1 million API calls: FREE

**CloudWatch Logs:**
- First 5 GB of ingestion: FREE
- First 5 GB of storage: FREE

Remember to destroy resources after learning to avoid any charges. The Lambda function in this scenario is very lightweight and will likely stay well within free tier limits even with testing.
