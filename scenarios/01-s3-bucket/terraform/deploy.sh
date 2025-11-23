#!/bin/bash
set -e

echo "==================================="
echo "Deploying Infrastructure with Terraform"
echo "==================================="

# Initialize Terraform if needed
if [ ! -d ".terraform" ]; then
    echo "Initializing Terraform..."
    terraform init
fi

# Format check
echo "Checking Terraform formatting..."
terraform fmt -check || terraform fmt

# Validate configuration
echo "Validating Terraform configuration..."
terraform validate

# Plan deployment
echo "Planning deployment..."
terraform plan

# Apply with auto-approve
echo "Applying infrastructure changes..."
terraform apply -auto-approve

# Show outputs
echo ""
echo "==================================="
echo "Deployment Complete!"
echo "==================================="
terraform output

echo ""
echo "Bucket created successfully!"
echo "Run './destroy.sh' to remove resources when done."
