#!/bin/bash
set -e

echo "==================================="
echo "Deploying Infrastructure with AWS CDK"
echo "==================================="

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Synthesize CloudFormation template
echo "Synthesizing CDK stack..."
npm run build
npx cdk synth

# Deploy stack
echo "Deploying CDK stack..."
npx cdk deploy --require-approval never

echo ""
echo "==================================="
echo "Deployment Complete!"
echo "==================================="

# Show outputs
echo "Stack outputs:"
aws cloudformation describe-stacks \
  --stack-name IacLearningCdkStack \
  --query 'Stacks[0].Outputs' \
  --output table 2>/dev/null || echo "Unable to fetch outputs via AWS CLI"

echo ""
echo "Bucket created successfully!"
echo "Run './destroy.sh' to remove resources when done."
