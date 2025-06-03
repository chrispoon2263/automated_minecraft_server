#!/bin/bash
KEY_NAME="minecraft_key"
KEY_PATH="$HOME/.ssh/${KEY_NAME}"
S3_BUCKET="chris-terraform-minecraft-bucket"
REGION="us-west-2"


#!/bin/bash
echo "Please enter your AWS credentials (inputs will be hidden)..."
echo -n "AWS_ACCESS_KEY_ID = "
read -s AWS_ACCESS_KEY_ID
echo 

echo -n "AWS_SECRET_ACCESS_KEY = "
read -s AWS_SECRET_ACCESS_KEY
echo

echo -n "AWS_SESSION_TOKEN = "
read -s AWS_SESSION_TOKEN
echo

export AWS_ACCESS_KEY_ID
export AWS_SECRET_ACCESS_KEY
export AWS_SESSION_TOKEN
echo "AWS credentials set for current shell"

# Check if key pair exists in AWS
aws ec2 describe-key-pairs --key-name "${KEY_NAME}" --region "$REGION" > /dev/null 2>&1
if [ $? -ne 0 ]; then
  echo "Creating SSH key locally and uploading public key to AWS..."

  # Create new key pair locally
  ssh-keygen -t rsa -b 4096 -f "$KEY_PATH" -N ""
  chmod 400 "${KEY_PATH}"

  # Import public key to AWS EC2
  aws ec2 import-key-pair \
    --key-name "$KEY_NAME" \
    --public-key-material fileb://"${KEY_PATH}.pub" \
    --region "$REGION"
else
  echo "AWS EC2 key pair '$KEY_NAME' already exists"
fi


# Check or create S3 bucket
aws s3api head-bucket --bucket "$S3_BUCKET" 2>/dev/null
if [ $? -ne 0 ]; then
  echo "Creating S3 bucket '$S3_BUCKET' in $REGION..."
  aws s3api create-bucket \
    --bucket "$S3_BUCKET" \
    --region "$REGION" \
    --create-bucket-configuration LocationConstraint="$REGION"
else
  echo "S3 bucket already exists"
fi

# Upload terraform state if it exists
aws s3 cp ./terraform/terraform.tfstate s3://$S3_BUCKET/terraform.tfstate --region $REGION || true

# Upload Minecraft server files
aws s3 cp ./server_files s3://$S3_BUCKET/server_files --region $REGION --recursive

echo "Initial set up all done! ... run \"make\" to deploy the EC2 instance"