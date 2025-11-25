# Local Environment Setup

This guide covers installing and configuring all the IaC tools needed for this repository.

## Prerequisites

- Linux/bash environment (WSL2, native Linux, or macOS)
- AWS CLI configured (see [AWS Setup Guide](01-aws-setup.md))
- Basic familiarity with command line

## Required Tools

1. **Terraform** - for Terraform implementation
2. **Node.js & npm** - for AWS CDK implementation
3. **AWS CDK CLI** - for CDK deployment
4. **AWS CLI** - for CloudFormation (already installed)

## Installing Terraform

### On Linux (Ubuntu/Debian)

```bash
# Add HashiCorp GPG key
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Add HashiCorp repository
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Update and install
sudo apt update
sudo apt install terraform

# Verify installation
terraform version
```

### On macOS

```bash
# Using Homebrew
brew tap hashicorp/tap
brew install hashicorp/tap/terraform

# Verify installation
terraform version
```

### Alternative: Download Binary Manually

```bash
# Download latest version (check https://www.terraform.io/downloads for latest)
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip

# Unzip
unzip terraform_1.6.0_linux_amd64.zip

# Move to PATH
sudo mv terraform /usr/local/bin/

# Verify
terraform version
```

Expected output:
```
Terraform v1.6.0
```

## Installing Node.js and npm

### On Linux (Ubuntu/Debian)

```bash
# Using NodeSource repository for latest LTS
curl -fsSL https://deb.nodesource.com/setup_lts.x | sudo -E bash -
sudo apt-get install -y nodejs

# Verify installation
node --version
npm --version
```

### On macOS

```bash
# Using Homebrew
brew install node

# Verify installation
node --version
npm --version
```

### Alternative: Using NVM (Node Version Manager)

```bash
# Install NVM
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash

# Reload shell
source ~/.bashrc  # or source ~/.zshrc

# Install Node.js LTS
nvm install --lts
nvm use --lts

# Verify
node --version
npm --version
```

Expected output:
```
v18.x.x  (or v20.x.x)
9.x.x (or 10.x.x)
```

## Installing AWS CDK CLI

Once Node.js is installed:

```bash
# Install AWS CDK globally
npm install -g aws-cdk

# Verify installation
cdk --version
```

Expected output:
```
2.100.0 (build xxxxxxx)
```

### Bootstrap CDK (Required for CDK)

CDK requires a one-time bootstrap in your AWS account/region:

```bash
# Bootstrap CDK in your default region
cdk bootstrap

# Or specify region explicitly
cdk bootstrap aws://ACCOUNT-NUMBER/REGION
```

Example:
```bash
cdk bootstrap aws://123456789012/us-east-1
```

This creates necessary S3 buckets and IAM roles for CDK deployments.

## AWS CloudFormation

CloudFormation is included with AWS CLI, no additional installation needed!

Verify:
```bash
aws cloudformation help
```

## Optional: Install jq for JSON Processing

`jq` is useful for parsing JSON outputs from AWS CLI:

```bash
# On Ubuntu/Debian
sudo apt install jq

# On macOS
brew install jq

# Verify
jq --version
```

## Verify All Tools

Run this script to verify all tools are installed:

```bash
#!/bin/bash
echo "=== Checking IaC Tools Installation ==="
echo ""

# AWS CLI
echo -n "AWS CLI: "
if command -v aws &> /dev/null; then
    aws --version
else
    echo "❌ Not installed"
fi

# Terraform
echo -n "Terraform: "
if command -v terraform &> /dev/null; then
    terraform version | head -n1
else
    echo "❌ Not installed"
fi

# Node.js
echo -n "Node.js: "
if command -v node &> /dev/null; then
    node --version
else
    echo "❌ Not installed"
fi

# npm
echo -n "npm: "
if command -v npm &> /dev/null; then
    npm --version
else
    echo "❌ Not installed"
fi

# CDK
echo -n "AWS CDK: "
if command -v cdk &> /dev/null; then
    cdk --version
else
    echo "❌ Not installed"
fi

# jq (optional)
echo -n "jq (optional): "
if command -v jq &> /dev/null; then
    jq --version
else
    echo "⚠️  Not installed (optional)"
fi

echo ""
echo "=== AWS Configuration Check ==="
aws sts get-caller-identity 2>/dev/null && echo "✅ AWS credentials configured" || echo "❌ AWS credentials not configured"
```

Save this as `check-tools.sh`, make it executable, and run it:

```bash
chmod +x check-tools.sh
./check-tools.sh
```

## Directory Setup

Clone the repository and navigate to it:

```bash
git clone https://github.com/raysihto-playground-25/aws-iac-sandbox.git
cd aws-iac-sandbox
```

## Tool-Specific Setup

### Terraform Setup

```bash
cd terraform
terraform init
```

This downloads required providers and sets up the backend.

### CDK Setup

```bash
cd cdk
npm install
```

This installs CDK dependencies defined in `package.json`.

### CloudFormation Setup

No additional setup needed! CloudFormation uses AWS CLI directly.

## Environment Variables

Create a `.env` file in the repository root (already in .gitignore):

```bash
# Optional: Override default region
export AWS_DEFAULT_REGION=us-east-1

# Optional: Set project prefix for resource naming
export PROJECT_PREFIX=myproject
```

Load it:
```bash
source .env
```

## IDE Setup (Optional)

### VS Code Extensions

Recommended extensions for VS Code:

1. **HashiCorp Terraform** - Syntax highlighting and validation for Terraform
2. **AWS Toolkit** - AWS resource management from VS Code
3. **YAML** - For CloudFormation templates

Install:
```bash
code --install-extension hashicorp.terraform
code --install-extension amazonwebservices.aws-toolkit-vscode
code --install-extension redhat.vscode-yaml
```

## Troubleshooting

### Terraform: "Failed to install provider"
- Check internet connection
- Try `terraform init -upgrade`
- Clear cache: `rm -rf .terraform/`

### CDK: "Cannot find module"
- Run `npm install` in the cdk directory
- Check Node.js version is compatible (v14+)

### CDK Bootstrap fails
- Verify AWS credentials with `aws sts get-caller-identity`
- Ensure IAM user has necessary permissions
- Try specifying account and region explicitly

### npm install fails with permissions error
- Don't use `sudo` with npm install
- Fix npm permissions: https://docs.npmjs.com/resolving-eacces-permissions-errors-when-installing-packages-globally
- Or use nvm to manage Node.js

## Next Steps

Once all tools are installed and verified:
- [Deployment Guide](03-deployment-guide.md) - Learn how to deploy with each tool
- Try the implementations:
  - [Terraform](../terraform/README.md)
  - [AWS CDK](../cdk/README.md)
  - [CloudFormation](../cloudformation/README.md)
