# AWS IaC Tools Comparison

A learning repository comparing major Infrastructure as Code (IaC) tools for AWS by implementing the same simple architecture using different tools.

## Overview

This repository demonstrates how to deploy identical AWS infrastructure using three popular IaC tools:
- **Terraform** - HashiCorp's open-source IaC tool
- **AWS CDK (TypeScript)** - AWS's Cloud Development Kit using TypeScript
- **AWS CloudFormation** - AWS's native IaC service

Each implementation creates the same AWS resources: a versioned S3 bucket with server-side encryption, demonstrating how different tools approach the same infrastructure problem.

## Repository Structure

```
.
├── docs/                          # Documentation
│   ├── 01-aws-setup.md           # IAM user and AWS CLI setup
│   ├── 02-local-environment.md   # Local development environment setup
│   ├── 03-deployment-guide.md    # Deployment and verification guide
│   └── 04-github-actions.md      # CI/CD setup with GitHub Actions
├── terraform/                     # Terraform implementation
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── deploy.sh
│   ├── destroy.sh
│   └── README.md
├── cdk/                          # AWS CDK (TypeScript) implementation
│   ├── bin/
│   ├── lib/
│   ├── cdk.json
│   ├── package.json
│   ├── deploy.sh
│   ├── destroy.sh
│   └── README.md
├── cloudformation/               # CloudFormation implementation
│   ├── template.yaml
│   ├── deploy.sh
│   ├── destroy.sh
│   └── README.md
├── .github/
│   └── workflows/                # GitHub Actions workflows
│       ├── terraform.yml
│       ├── cdk.yml
│       └── cloudformation.yml
└── scripts/                      # Utility scripts
    └── verify-resources.sh       # Verify all implementations create equivalent resources
```

## Quick Start

1. **Prerequisites**: Follow [AWS Setup Guide](docs/01-aws-setup.md) to configure IAM user and AWS CLI
2. **Environment**: Follow [Local Environment Setup](docs/02-local-environment.md) to install required tools
3. **Deploy**: Choose an implementation and follow its README
4. **Verify**: Use the verification script to confirm resources match

## What You'll Learn

- How to set up AWS credentials for IaC tools
- Syntax and structure differences between IaC tools
- Deployment and state management approaches
- Best practices for each tool
- How to implement CI/CD pipelines for infrastructure
- How to verify infrastructure consistency across tools

## AWS Resources Created

Each implementation creates:
- **S3 Bucket** with:
  - Versioning enabled
  - Server-side encryption (AES256)
  - Block public access enabled
  - Unique naming using random suffix

All implementations are designed to stay within AWS Free Tier limits.

## Getting Started

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

3. Try each implementation:
   - [Terraform](terraform/README.md)
   - [AWS CDK](cdk/README.md)
   - [CloudFormation](cloudformation/README.md)

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