#!/bin/bash

# Script to verify all IaC implementations create equivalent resources

set -e

echo "================================================"
echo "AWS IaC Tools - Resource Verification Script"
echo "================================================"
echo ""

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."
if ! command_exists aws; then
    echo -e "${RED}✗ AWS CLI not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ AWS CLI found${NC}"

# Verify AWS credentials
if ! aws sts get-caller-identity &>/dev/null; then
    echo -e "${RED}✗ AWS credentials not configured${NC}"
    exit 1
fi
echo -e "${GREEN}✓ AWS credentials configured${NC}"
echo ""

# Function to get bucket details
get_bucket_details() {
    local bucket_name=$1
    
    if [ -z "$bucket_name" ]; then
        echo "not_found"
        return
    fi
    
    # Check if bucket exists
    if ! aws s3api head-bucket --bucket "$bucket_name" 2>/dev/null; then
        echo "not_found"
        return
    fi
    
    echo "Bucket: $bucket_name"
    
    # Get versioning
    versioning=$(aws s3api get-bucket-versioning --bucket "$bucket_name" --query 'Status' --output text 2>/dev/null || echo "NONE")
    echo "  Versioning: $versioning"
    
    # Get encryption
    encryption=$(aws s3api get-bucket-encryption --bucket "$bucket_name" --query 'ServerSideEncryptionConfiguration.Rules[0].ApplyServerSideEncryptionByDefault.SSEAlgorithm' --output text 2>/dev/null || echo "NONE")
    echo "  Encryption: $encryption"
    
    # Get public access block
    block_public=$(aws s3api get-public-access-block --bucket "$bucket_name" --query 'PublicAccessBlockConfiguration.BlockPublicAcls' --output text 2>/dev/null || echo "false")
    echo "  Block Public Access: $block_public"
    
    # Get tags
    echo "  Tags:"
    aws s3api get-bucket-tagging --bucket "$bucket_name" --query 'TagSet[*].[Key,Value]' --output text 2>/dev/null | while read key value; do
        echo "    $key: $value"
    done || echo "    No tags found"
    
    echo ""
}

# Check Terraform deployment
echo "================================================"
echo "Checking Terraform Deployment"
echo "================================================"
if [ -f "terraform/terraform.tfstate" ]; then
    echo -e "${GREEN}✓ Terraform state found${NC}"
    
    # Get bucket name from Terraform output
    cd terraform
    if command_exists terraform; then
        TERRAFORM_BUCKET=$(terraform output -raw bucket_name 2>/dev/null || echo "")
        cd ..
        
        if [ ! -z "$TERRAFORM_BUCKET" ]; then
            echo -e "${GREEN}✓ Terraform bucket found: $TERRAFORM_BUCKET${NC}"
            get_bucket_details "$TERRAFORM_BUCKET"
        else
            echo -e "${YELLOW}⚠ Terraform deployed but bucket name not found in outputs${NC}"
            cd ..
        fi
    else
        echo -e "${YELLOW}⚠ Terraform not installed, cannot retrieve outputs${NC}"
        cd ..
    fi
else
    echo -e "${YELLOW}⚠ Terraform not deployed${NC}"
    echo ""
fi

# Check CDK deployment
echo "================================================"
echo "Checking CDK Deployment"
echo "================================================"
CDK_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name IacLearningCdkStack \
    --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
    --output text 2>/dev/null || echo "")

if [ ! -z "$CDK_BUCKET" ] && [ "$CDK_BUCKET" != "None" ]; then
    echo -e "${GREEN}✓ CDK stack found${NC}"
    echo -e "${GREEN}✓ CDK bucket found: $CDK_BUCKET${NC}"
    get_bucket_details "$CDK_BUCKET"
else
    echo -e "${YELLOW}⚠ CDK not deployed${NC}"
    echo ""
fi

# Check CloudFormation deployment
echo "================================================"
echo "Checking CloudFormation Deployment"
echo "================================================"
CFN_BUCKET=$(aws cloudformation describe-stacks \
    --stack-name IacLearningCfnStack \
    --query 'Stacks[0].Outputs[?OutputKey==`BucketName`].OutputValue' \
    --output text 2>/dev/null || echo "")

if [ ! -z "$CFN_BUCKET" ] && [ "$CFN_BUCKET" != "None" ]; then
    echo -e "${GREEN}✓ CloudFormation stack found${NC}"
    echo -e "${GREEN}✓ CloudFormation bucket found: $CFN_BUCKET${NC}"
    get_bucket_details "$CFN_BUCKET"
else
    echo -e "${YELLOW}⚠ CloudFormation not deployed${NC}"
    echo ""
fi

# Summary
echo "================================================"
echo "Summary"
echo "================================================"
echo ""

# Count deployed implementations
deployed=0
[ ! -z "$TERRAFORM_BUCKET" ] && deployed=$((deployed+1))
[ ! -z "$CDK_BUCKET" ] && [ "$CDK_BUCKET" != "None" ] && deployed=$((deployed+1))
[ ! -z "$CFN_BUCKET" ] && [ "$CFN_BUCKET" != "None" ] && deployed=$((deployed+1))

echo "Deployed implementations: $deployed/3"
echo ""

if [ $deployed -eq 0 ]; then
    echo -e "${YELLOW}No implementations are currently deployed.${NC}"
    echo "Deploy one or more implementations to verify:"
    echo "  - terraform: cd terraform && ./deploy.sh"
    echo "  - cdk: cd cdk && ./deploy.sh"
    echo "  - cloudformation: cd cloudformation && ./deploy.sh"
elif [ $deployed -eq 3 ]; then
    echo -e "${GREEN}All three implementations are deployed!${NC}"
    echo ""
    echo "Verification Summary:"
    echo "  All implementations should have:"
    echo "    ✓ Versioning: Enabled"
    echo "    ✓ Encryption: AES256"
    echo "    ✓ Block Public Access: true"
    echo "    ✓ Tags: Environment=learning, ManagedBy=<tool>"
    echo ""
    echo -e "${GREEN}Review the details above to confirm configurations match.${NC}"
else
    echo -e "${YELLOW}$deployed implementation(s) deployed.${NC}"
    echo "Deploy remaining implementations to compare:"
    [ -z "$TERRAFORM_BUCKET" ] && echo "  - terraform: cd terraform && ./deploy.sh"
    [ -z "$CDK_BUCKET" ] || [ "$CDK_BUCKET" == "None" ] && echo "  - cdk: cd cdk && ./deploy.sh"
    [ -z "$CFN_BUCKET" ] || [ "$CFN_BUCKET" == "None" ] && echo "  - cloudformation: cd cloudformation && ./deploy.sh"
fi

echo ""
echo "================================================"
