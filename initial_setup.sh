#!/bin/bash

# Check if S3 bucket has been created
if aws s3api head-bucket --bucket chris-terraform-minecraft-bucket 2>/dev/null; then
  echo "Bucket already exists"
else
  # Create the AWS key pair and place into ~/.ssh/mineraft_key.pm
  echo "Generating AWS ssh key pair"
  mkdir -p ~/.ssh
  rm -f ~/.ssh/minecraft_key.pem
  aws ec2 create-key-pair \
    --key-name minecraft_key \
    --query 'KeyMaterial' \
    --output text > ~/.ssh/minecraft_key.pem
  chmod 400 ~/.ssh/minecraft_key.pem
  
  # provision an S3 bucket on AWS
  echo "Creating S3 bucket, initial Minecraft server files, and terraformt.tfstate..."
  aws s3api create-bucket --bucket chris-terraform-minecraft-bucket \
    --region us-west-2 --create-bucket-configuration LocationConstraint=us-west-2
  # Copy terraform on local machine to S3 bucket
  aws s3 cp ./terraform/terraform.tfstate s3://chris-terraform-minecraft-bucket/terraform.tfstate --region us-west-2

  # Copy minecraft server files to S3 bucket
  aws s3 cp ./server_files s3://chris-terraform-minecraft-bucket/server_files --region us-west-2 --recursive
fi

# Bandaid solution using environment variables to sync s3
# unable to create IAM roles on student learner account (normally would never do this!)
export AWS_ACCESS_KEY_ID=$(aws configure get aws_access_key_id)
export AWS_SECRET_ACCESS_KEY=$(aws configure get aws_secret_access_key)
export AWS_SESSION_TOKEN=$(aws configure get aws_session_token)