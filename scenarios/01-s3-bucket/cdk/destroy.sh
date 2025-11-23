#!/bin/bash
set -e

echo "==================================="
echo "Destroying Infrastructure with AWS CDK"
echo "==================================="

# Check if stack exists
if ! aws cloudformation describe-stacks --stack-name IacLearningCdkStack &>/dev/null; then
    echo "Stack 'IacLearningCdkStack' not found. Nothing to destroy."
    exit 0
fi

# Destroy stack
echo "Destroying CDK stack..."
npx cdk destroy --force

echo ""
echo "==================================="
echo "Destruction Complete!"
echo "==================================="
echo "All CDK-managed resources have been removed."
