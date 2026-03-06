#!/bin/bash

# Quick Start Script for AWS CI/CD Setup
# This script helps you set up the basic AWS resources quickly

set -e

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}"
echo "╔═══════════════════════════════════════════════════════╗"
echo "║                                                       ║"
echo "║     AWS CI/CD Quick Start Setup                      ║"
echo "║     Next.js → S3 → CloudFront                        ║"
echo "║                                                       ║"
echo "╚═══════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Check prerequisites
echo -e "${YELLOW}Checking prerequisites...${NC}"

if ! command -v aws &> /dev/null; then
    echo -e "${RED}❌ AWS CLI not found${NC}"
    echo "Install it from: https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html"
    exit 1
fi
echo -e "${GREEN}✓ AWS CLI found${NC}"

if ! aws sts get-caller-identity &> /dev/null; then
    echo -e "${RED}❌ AWS credentials not configured${NC}"
    echo "Run: aws configure"
    exit 1
fi
echo -e "${GREEN}✓ AWS credentials configured${NC}"

if ! command -v git &> /dev/null; then
    echo -e "${RED}❌ Git not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ Git found${NC}"

if ! command -v npm &> /dev/null; then
    echo -e "${RED}❌ npm not found${NC}"
    exit 1
fi
echo -e "${GREEN}✓ npm found${NC}"

echo ""

# Get user input
echo -e "${BLUE}Please provide the following information:${NC}"
echo ""

read -p "Project name (e.g., nextjs-chat-app): " PROJECT_NAME
if [ -z "$PROJECT_NAME" ]; then
    echo -e "${RED}Project name is required${NC}"
    exit 1
fi

# Set AWS region
echo ""
echo "Available regions:"
echo "1) us-east-1 (US East - N. Virginia) - Recommended for CloudFront"
echo "2) us-west-2 (US West - Oregon)"
echo "3) eu-west-1 (Europe - Ireland)"
echo "4) ap-southeast-1 (Asia Pacific - Singapore)"
read -p "Select region (1-4): " REGION_CHOICE

case $REGION_CHOICE in
    1) AWS_REGION="us-east-1" ;;
    2) AWS_REGION="us-west-2" ;;
    3) AWS_REGION="eu-west-1" ;;
    4) AWS_REGION="ap-southeast-1" ;;
    *) AWS_REGION="us-east-1" ;;
esac

echo ""
read -p "Enter your OPENAI_API_KEY (or press Enter to skip): " OPENAI_API_KEY

# Get AWS account ID
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)

# Summary
echo ""
echo -e "${BLUE}Configuration Summary:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Project Name:    $PROJECT_NAME"
echo "AWS Region:      $AWS_REGION"
echo "AWS Account:     $AWS_ACCOUNT_ID"
echo "OPENAI_API_KEY:  $([ -n "$OPENAI_API_KEY" ] && echo "Set ✓" || echo "Not set")"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

read -p "Continue with setup? (y/n): " CONFIRM
if [ "$CONFIRM" != "y" ]; then
    echo "Setup cancelled"
    exit 0
fi

# Derived names
HOSTING_BUCKET="${PROJECT_NAME}-hosting"
ENV_BUCKET="${PROJECT_NAME}-env-vars"
CODEBUILD_ROLE="${PROJECT_NAME}-codebuild-role"
PIPELINE_ROLE="${PROJECT_NAME}-pipeline-role"

echo ""
echo -e "${BLUE}Starting AWS resource creation...${NC}"
echo ""

# Create S3 hosting bucket
echo -e "${YELLOW}[1/5] Creating S3 hosting bucket...${NC}"
if aws s3 ls "s3://${HOSTING_BUCKET}" 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3 mb "s3://${HOSTING_BUCKET}" --region "$AWS_REGION" 2>/dev/null || {
        echo -e "${RED}Failed to create hosting bucket${NC}"
        echo "Note: Bucket names must be globally unique. Try a different project name."
        exit 1
    }
    echo -e "${GREEN}✓ Created: s3://${HOSTING_BUCKET}${NC}"
else
    echo -e "${YELLOW}Bucket already exists: ${HOSTING_BUCKET}${NC}"
fi

# Create environment variables bucket
echo -e "${YELLOW}[2/5] Creating environment variables bucket...${NC}"
if aws s3 ls "s3://${ENV_BUCKET}" 2>&1 | grep -q 'NoSuchBucket'; then
    aws s3 mb "s3://${ENV_BUCKET}" --region "$AWS_REGION" 2>/dev/null || {
        echo -e "${RED}Failed to create env bucket${NC}"
        exit 1
    }
    
    # Block public access
    aws s3api put-public-access-block \
        --bucket "$ENV_BUCKET" \
        --public-access-block-configuration \
        "BlockPublicAcls=true,IgnorePublicAcls=true,BlockPublicPolicy=true,RestrictPublicBuckets=true" \
        2>/dev/null
    
    echo -e "${GREEN}✓ Created: s3://${ENV_BUCKET}${NC}"
else
    echo -e "${YELLOW}Bucket already exists: ${ENV_BUCKET}${NC}"
fi

# Upload environment variables
if [ -n "$OPENAI_API_KEY" ]; then
    echo -e "${YELLOW}[3/5] Uploading environment variables...${NC}"
    
    cat > /tmp/.env.production <<EOF
OPENAI_API_KEY=$OPENAI_API_KEY
EOF
    
    aws s3 cp /tmp/.env.production "s3://${ENV_BUCKET}/.env.production" 2>/dev/null
    rm /tmp/.env.production
    
    echo -e "${GREEN}✓ Environment variables uploaded${NC}"
else
    echo -e "${YELLOW}[3/5] Skipping environment variables (none provided)${NC}"
fi

# Create CodeBuild IAM role
echo -e "${YELLOW}[4/5] Creating IAM roles...${NC}"

# CodeBuild role
cat > /tmp/codebuild-trust.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "codebuild.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF

if aws iam get-role --role-name "$CODEBUILD_ROLE" 2>/dev/null >/dev/null; then
    echo -e "${YELLOW}  CodeBuild role already exists${NC}"
else
    aws iam create-role \
        --role-name "$CODEBUILD_ROLE" \
        --assume-role-policy-document file:///tmp/codebuild-trust.json \
        2>/dev/null >/dev/null
    
    # Attach policies
    aws iam attach-role-policy \
        --role-name "$CODEBUILD_ROLE" \
        --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess \
        2>/dev/null
    
    aws iam attach-role-policy \
        --role-name "$CODEBUILD_ROLE" \
        --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess \
        2>/dev/null
    
    aws iam attach-role-policy \
        --role-name "$CODEBUILD_ROLE" \
        --policy-arn arn:aws:iam::aws:policy/CloudFrontFullAccess \
        2>/dev/null
    
    echo -e "${GREEN}  ✓ Created CodeBuild role${NC}"
fi

# CodePipeline role
cat > /tmp/pipeline-trust.json <<EOF
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {"Service": "codepipeline.amazonaws.com"},
    "Action": "sts:AssumeRole"
  }]
}
EOF

if aws iam get-role --role-name "$PIPELINE_ROLE" 2>/dev/null >/dev/null; then
    echo -e "${YELLOW}  Pipeline role already exists${NC}"
else
    aws iam create-role \
        --role-name "$PIPELINE_ROLE" \
        --assume-role-policy-document file:///tmp/pipeline-trust.json \
        2>/dev/null >/dev/null
    
    # Attach policies
    aws iam attach-role-policy \
        --role-name "$PIPELINE_ROLE" \
        --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess \
        2>/dev/null
    
    aws iam attach-role-policy \
        --role-name "$PIPELINE_ROLE" \
        --policy-arn arn:aws:iam::aws:policy/AWSCodeBuildAdminAccess \
        2>/dev/null
    
    echo -e "${GREEN}  ✓ Created Pipeline role${NC}"
fi

rm /tmp/codebuild-trust.json /tmp/pipeline-trust.json

# Update buildspec.yml
echo -e "${YELLOW}[5/5] Updating buildspec.yml...${NC}"

if [ -f "buildspec.yml" ]; then
    # Update ENV_BUCKET in buildspec.yml
    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS
        sed -i '' "s|ENV_BUCKET:.*|ENV_BUCKET: \"$ENV_BUCKET\"|g" buildspec.yml
    else
        # Linux
        sed -i "s|ENV_BUCKET:.*|ENV_BUCKET: \"$ENV_BUCKET\"|g" buildspec.yml
    fi
    echo -e "${GREEN}✓ buildspec.yml updated${NC}"
else
    echo -e "${RED}buildspec.yml not found${NC}"
fi

# Save configuration
cat > aws-config.env <<EOF
# AWS CI/CD Configuration
# Generated: $(date)

PROJECT_NAME="$PROJECT_NAME"
AWS_REGION="$AWS_REGION"
AWS_ACCOUNT_ID="$AWS_ACCOUNT_ID"

HOSTING_BUCKET="$HOSTING_BUCKET"
ENV_BUCKET="$ENV_BUCKET"

CODEBUILD_ROLE="$CODEBUILD_ROLE"
PIPELINE_ROLE="$PIPELINE_ROLE"

# CloudFront Distribution ID (add this after creating CloudFront distribution)
CLOUDFRONT_DISTRIBUTION_ID=""

# Git repository
GITHUB_REPO_URL=""
GITHUB_BRANCH="main"
EOF

echo ""
echo -e "${GREEN}╔═══════════════════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}║     ✅ AWS Resources Created Successfully!            ║${NC}"
echo -e "${GREEN}║                                                       ║${NC}"
echo -e "${GREEN}╚═══════════════════════════════════════════════════════╝${NC}"
echo ""

echo -e "${BLUE}Created Resources:${NC}"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "S3 Hosting:      s3://${HOSTING_BUCKET}"
echo "S3 Environment:  s3://${ENV_BUCKET}"
echo "CodeBuild Role:  $CODEBUILD_ROLE"
echo "Pipeline Role:   $PIPELINE_ROLE"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

echo -e "${YELLOW}Next Steps:${NC}"
echo ""
echo "1. Create CloudFront Distribution:"
echo "   https://console.aws.amazon.com/cloudfront/v3/home#/distributions/create"
echo ""
echo "2. Create CodeBuild Project:"
echo "   https://console.aws.amazon.com/codesuite/codebuild/projects/new"
echo ""
echo "3. Create CodePipeline:"
echo "   https://console.aws.amazon.com/codesuite/codepipeline/pipelines/new"
echo ""
echo -e "${BLUE}📖 For detailed instructions, see:${NC}"
echo "   STEP_BY_STEP_IMPLEMENTATION.md"
echo ""
echo -e "${GREEN}Configuration saved to: aws-config.env${NC}"
echo ""
echo -e "${YELLOW}TIP: Source the config file to use these variables:${NC}"
echo "   source aws-config.env"
echo ""
