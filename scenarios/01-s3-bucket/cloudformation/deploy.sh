#!/bin/bash
set -e

STACK_NAME=${STACK_NAME:-"IacLearningCfnStack"}

echo "==================================="
echo "Deploying Infrastructure with CloudFormation"
echo "==================================="

# Validate template
echo "Validating CloudFormation template..."
aws cloudformation validate-template --template-body file://template.yaml > /dev/null
echo "✓ Template is valid"

# Check if stack exists
if aws cloudformation describe-stacks --stack-name $STACK_NAME &>/dev/null; then
    echo "Stack exists. Updating..."
    
    # Create change set
    CHANGE_SET_NAME="update-$(date +%s)"
    aws cloudformation create-change-set \
      --stack-name $STACK_NAME \
      --template-body file://template.yaml \
      --change-set-name $CHANGE_SET_NAME \
      --capabilities CAPABILITY_IAM
    
    echo "Waiting for change set creation..."
    aws cloudformation wait change-set-create-complete \
      --stack-name $STACK_NAME \
      --change-set-name $CHANGE_SET_NAME
    
    # Execute change set
    echo "Executing change set..."
    aws cloudformation execute-change-set \
      --stack-name $STACK_NAME \
      --change-set-name $CHANGE_SET_NAME
    
    echo "Waiting for stack update to complete..."
    aws cloudformation wait stack-update-complete --stack-name $STACK_NAME
else
    echo "Creating new stack..."
    aws cloudformation create-stack \
      --stack-name $STACK_NAME \
      --template-body file://template.yaml \
      --capabilities CAPABILITY_IAM
    
    echo "Waiting for stack creation to complete..."
    aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
fi

echo ""
echo "==================================="
echo "Deployment Complete!"
echo "==================================="

# Show outputs
echo "Stack outputs:"
aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --query 'Stacks[0].Outputs' \
  --output table

echo ""
echo "Bucket created successfully!"
echo "Run './destroy.sh' to remove resources when done."
