#!/bin/bash

# AWS CI/CD Setup Script for Next.js
# This script automates the creation of AWS resources for your CI/CD pipeline

set -e  # Exit on error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Configuration - UPDATE THESE VALUES
PROJECT_NAME="nextjs-app"
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="509194952232"  # Replace with your AWS account ID
GITHUB_REPO="valeriiayarzhemska/openai-chat-integration"    # Replace with your GitHub repo

# Derived names
HOSTING_BUCKET="${PROJECT_NAME}-hosting"
ENV_BUCKET="${PROJECT_NAME}-env-vars"
CODEBUILD_PROJECT="${PROJECT_NAME}-build"
PIPELINE_NAME="${PROJECT_NAME}-pipeline"
CODEBUILD_ROLE="${PROJECT_NAME}-codebuild-role"
PIPELINE_ROLE="${PROJECT_NAME}-pipeline-role"

echo -e "${GREEN}========================================${NC}"
echo -e "${GREEN}AWS CI/CD Setup for Next.js${NC}"
echo -e "${GREEN}========================================${NC}"
echo ""
echo "Project: $PROJECT_NAME"
echo "Region: $AWS_REGION"
echo ""

# Function to check if AWS CLI is installed
check_aws_cli() {
    if ! command -v aws &> /dev/null; then
        echo -e "${RED}Error: AWS CLI is not installed${NC}"
        echo "Please install it from: https://aws.amazon.com/cli/"
        exit 1
    fi
    echo -e "${GREEN}✓ AWS CLI found${NC}"
}

# Function to check AWS credentials
check_aws_credentials() {
    if ! aws sts get-caller-identity &> /dev/null; then
        echo -e "${RED}Error: AWS credentials not configured${NC}"
        echo "Run: aws configure"
        exit 1
    fi
    echo -e "${GREEN}✓ AWS credentials configured${NC}"
}

# Function to create S3 hosting bucket
create_hosting_bucket() {
    echo ""
    echo -e "${YELLOW}Creating S3 hosting bucket...${NC}"
    
    if aws s3 ls "s3://${HOSTING_BUCKET}" 2>&1 | grep -q 'NoSuchBucket'; then
        aws s3 mb "s3://${HOSTING_BUCKET}" --region "$AWS_REGION"
        
        # Enable static website hosting
        aws s3 website "s3://${HOSTING_BUCKET}" \
            --index-document index.html \
            --error-document 404.html
        
        echo -e "${GREEN}✓ Hosting bucket created: ${HOSTING_BUCKET}${NC}"
    else
        echo -e "${YELLOW}Bucket already exists: ${HOSTING_BUCKET}${NC}"
    fi
}

# Function to create environment variables bucket
create_env_bucket() {
    echo ""
    echo -e "${YELLOW}Creating environment variables bucket...${NC}"
    
    if aws s3 ls "s3://${ENV_BUCKET}" 2>&1 | grep -q 'NoSuchBucket'; then
        aws s3 mb "s3://${ENV_BUCKET}" --region "$AWS_REGION"
        
        # Block all public access
        aws s3api put-public-access-block \
            --bucket "$ENV_BUCKET" \
            --public-access-block-configuration \
            "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true"
        
        echo -e "${GREEN}✓ Environment bucket created: ${ENV_BUCKET}${NC}"
    else
        echo -e "${YELLOW}Bucket already exists: ${ENV_BUCKET}${NC}"
    fi
}

# Function to store environment variables in Parameter Store
store_env_variables() {
    echo ""
    echo -e "${YELLOW}Storing environment variables in Parameter Store...${NC}"
    
    read -p "Enter your OPENAI_API_KEY (or press Enter to skip): " openai_key
    
    if [ -n "$openai_key" ]; then
        aws ssm put-parameter \
            --name "/${PROJECT_NAME}/prod/OPENAI_API_KEY" \
            --value "$openai_key" \
            --type "SecureString" \
            --overwrite \
            --region "$AWS_REGION" 2>/dev/null || true
        
        echo -e "${GREEN}✓ Environment variables stored${NC}"
    else
        echo -e "${YELLOW}Skipped storing environment variables${NC}"
    fi
}

# Function to create IAM role for CodeBuild
create_codebuild_role() {
    echo ""
    echo -e "${YELLOW}Creating IAM role for CodeBuild...${NC}"
    
    # Trust policy
    cat > /tmp/codebuild-trust-policy.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF

    # Create role
    aws iam create-role \
        --role-name "$CODEBUILD_ROLE" \
        --assume-role-policy-document file:///tmp/codebuild-trust-policy.json 2>/dev/null || \
        echo -e "${YELLOW}Role may already exist${NC}"
    
    # Attach policies
    aws iam attach-role-policy \
        --role-name "$CODEBUILD_ROLE" \
        --policy-arn "arn:aws:iam::aws:policy/AmazonS3FullAccess" 2>/dev/null || true
    
    aws iam attach-role-policy \
        --role-name "$CODEBUILD_ROLE" \
        --policy-arn "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess" 2>/dev/null || true
    
    echo -e "${GREEN}✓ CodeBuild role created/updated${NC}"
}

# Function to create CloudFront distribution
create_cloudfront() {
    echo ""
    echo -e "${YELLOW}CloudFront distribution creation...${NC}"
    echo -e "${YELLOW}This step requires manual setup in AWS Console.${NC}"
    echo "1. Go to CloudFront Console"
    echo "2. Create Distribution"
    echo "3. Origin: ${HOSTING_BUCKET}.s3.amazonaws.com"
    echo "4. Enable Origin Access Control (OAC)"
    echo "5. Default Root Object: index.html"
    echo ""
    read -p "Press Enter once you've created the CloudFront distribution..."
}

# Function to display summary
display_summary() {
    echo ""
    echo -e "${GREEN}========================================${NC}"
    echo -e "${GREEN}Setup Summary${NC}"
    echo -e "${GREEN}========================================${NC}"
    echo ""
    echo "S3 Hosting Bucket: ${HOSTING_BUCKET}"
    echo "S3 Env Bucket: ${ENV_BUCKET}"
    echo "AWS Region: ${AWS_REGION}"
    echo ""
    echo -e "${YELLOW}Next Steps:${NC}"
    echo "1. Create CloudFront distribution (see AWS_DEPLOYMENT_GUIDE.md)"
    echo "2. Create CodeBuild project in AWS Console"
    echo "3. Create CodePipeline in AWS Console"
    echo "4. Connect your GitHub repository"
    echo "5. Push code to trigger the pipeline"
    echo ""
    echo -e "${GREEN}For detailed instructions, see AWS_DEPLOYMENT_GUIDE.md${NC}"
}

# Main execution
main() {
    check_aws_cli
    check_aws_credentials
    create_hosting_bucket
    create_env_bucket
    store_env_variables
    create_codebuild_role
    create_cloudfront
    display_summary
}

# Run main function
main
