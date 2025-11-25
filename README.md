# AWS IaC Tools Comparison

A hands-on learning repository comparing major Infrastructure as Code (IaC) tools for AWS across multiple real-world scenarios.

## Overview

This repository demonstrates how to deploy identical AWS infrastructure using three popular IaC tools:
- **Terraform** - HashiCorp's open-source IaC tool
- **AWS CDK (TypeScript)** - AWS's Cloud Development Kit using TypeScript
- **AWS CloudFormation** - AWS's native IaC service

Each scenario implements the same infrastructure with all three tools, allowing you to compare syntax, approaches, and workflows side-by-side.

## Repository Structure

```
.
├── docs/                          # Documentation
│   ├── 01-aws-setup.md           # IAM user and AWS CLI setup
│   ├── 02-local-environment.md   # Local development environment setup
│   ├── 03-deployment-guide.md    # Deployment and verification guide
│   └── 04-github-actions.md      # CI/CD setup with GitHub Actions
├── scenarios/                     # Infrastructure scenarios
│   ├── README.md                 # Scenarios overview
│   ├── 01-s3-bucket/            # S3 bucket scenario
│   │   ├── terraform/
│   │   ├── cdk/
│   │   └── cloudformation/
│   ├── 02-dynamodb-table/       # DynamoDB table scenario
│   │   ├── terraform/
│   │   ├── cdk/
│   │   └── cloudformation/
│   └── 03-lambda-api/           # Lambda + API Gateway scenario
│       ├── terraform/
│       ├── cdk/
│       └── cloudformation/
├── .github/
│   └── workflows/                # GitHub Actions workflows
└── scripts/                      # Utility scripts
    └── verify-resources.sh       # Verify implementations
```

## Quick Start

1. **Prerequisites**: Follow [AWS Setup Guide](docs/01-aws-setup.md) to configure IAM user and AWS CLI
2. **Environment**: Follow [Local Environment Setup](docs/02-local-environment.md) to install required tools
3. **Deploy**: Choose an implementation and follow its README
4. **Verify**: Use the verification script to confirm resources match

## What You'll Learn

- How to set up AWS credentials for IaC tools
- Syntax and structure differences between IaC tools across multiple scenarios
- Deployment and state management approaches
- Best practices for each tool
- How to implement CI/CD pipelines for infrastructure
- How to verify infrastructure consistency across tools
- Real-world infrastructure patterns: storage, databases, and serverless APIs

## AWS Resources & Scenarios

This repository includes three real-world infrastructure scenarios:

### Scenario 01: S3 Bucket with Versioning
- **Complexity:** ⭐ Beginner
- **Resources:** S3 bucket with versioning, encryption, and public access blocking
- **Use Cases:** Static websites, data storage, backups
- **Free Tier:** ✅ 5GB storage, 20K GET, 2K PUT requests/month

### Scenario 02: DynamoDB Table
- **Complexity:** ⭐⭐ Intermediate
- **Resources:** DynamoDB table with on-demand billing, point-in-time recovery
- **Use Cases:** User sessions, IoT data, mobile backends, real-time data
- **Free Tier:** ✅ 25GB storage, 25 WCU, 25 RCU

### Scenario 03: Lambda + API Gateway
- **Complexity:** ⭐⭐⭐ Advanced
- **Resources:** Lambda function, HTTP API Gateway, IAM roles, CloudWatch logs
- **Use Cases:** REST APIs, serverless backends, webhooks, microservices
- **Free Tier:** ✅ 1M requests, 400K GB-seconds compute/month

See [scenarios/README.md](scenarios/README.md) for detailed information about each scenario.

All implementations are designed to stay within AWS Free Tier limits.

## Getting Started

### Quick Start (Experienced Users)

See [QUICKSTART.md](QUICKSTART.md) for a condensed 5-minute guide.

### Detailed Setup (Recommended for Beginners)

1. Clone this repository:
   ```bash
   git clone https://github.com/raysihto-playground-25/aws-iac-sandbox.git
   cd aws-iac-sandbox
   ```

2. Follow the documentation in order:
   - [AWS Setup](docs/01-aws-setup.md)
   - [Local Environment](docs/02-local-environment.md)
   - [Deployment Guide](docs/03-deployment-guide.md)
   - [GitHub Actions](docs/04-github-actions.md) (optional)

3. Explore the scenarios:
   - [Scenarios Overview](scenarios/README.md)
   - Start with [Scenario 01 - S3 Bucket](scenarios/01-s3-bucket/)
   - Progress to [Scenario 02 - DynamoDB](scenarios/02-dynamodb-table/)
   - Advanced: [Scenario 03 - Lambda API](scenarios/03-lambda-api/)

## Cost Considerations

- S3 buckets are free to create
- S3 Free Tier includes 5GB storage, 20,000 GET requests, 2,000 PUT requests per month
- Remember to destroy resources after learning to avoid any charges

## Contributing

This is a learning repository. Feel free to:
- Add more IaC tool implementations
- Suggest more AWS scenarios
- Improve documentation
- Report issues

## License

MIT License - See LICENSE file for details