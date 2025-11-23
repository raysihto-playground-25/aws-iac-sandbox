#!/bin/bash
set -e

STACK_NAME=${STACK_NAME:-"IacLearningCfnStack"}

echo "==================================="
echo "Destroying Infrastructure with CloudFormation"
echo "==================================="

# Check if stack exists
if ! aws cloudformation describe-stacks --stack-name $STACK_NAME &>/dev/null; then
    echo "Stack '$STACK_NAME' not found. Nothing to destroy."
    exit 0
fi

# Get bucket name before deleting stack
BUCKET_NAME=$(aws cloudformation describe-stacks \
  --stack-name $STACK_NAME \
  --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
  --output text 2>/dev/null || echo "")

# Empty bucket if it exists
if [ ! -z "$BUCKET_NAME" ]; then
    echo "Emptying S3 bucket: $BUCKET_NAME"
    
    # Delete all objects
    aws s3 rm s3://$BUCKET_NAME --recursive 2>/dev/null || true
    
    # Delete all versions if versioning is enabled
    aws s3api delete-objects --bucket $BUCKET_NAME \
      --delete "$(aws s3api list-object-versions --bucket $BUCKET_NAME \
      --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' \
      --output json 2>/dev/null)" 2>/dev/null || true
    
    # Delete delete markers
    aws s3api delete-objects --bucket $BUCKET_NAME \
      --delete "$(aws s3api list-object-versions --bucket $BUCKET_NAME \
      --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' \
      --output json 2>/dev/null)" 2>/dev/null || true
    
    echo "✓ Bucket emptied"
fi

# Delete stack
echo "Deleting CloudFormation stack..."
aws cloudformation delete-stack --stack-name $STACK_NAME

echo "Waiting for stack deletion to complete..."
aws cloudformation wait stack-delete-complete --stack-name $STACK_NAME

echo ""
echo "==================================="
echo "Destruction Complete!"
echo "==================================="
echo "All CloudFormation-managed resources have been removed."
