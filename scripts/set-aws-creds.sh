#!/bin/bash

# This can be places anywhere on your machine that you wish
# so long as you give it execute permissions and set up your
# .zshrc as below:
# alias set-creds='source ~/scripts/set-aws-creds.sh'
# Then you can simply run 'set-cred' from any directory and
# your AWS creds will be set so you can use terraform locally.

# Set AWS credentials as environmental variables
export AWS_ACCESS_KEY_ID="YOUR_ACCESS_KEY_HERE"
export AWS_SECRET_ACCESS_KEY="YOUR_SECRET_KEY_HERE"
export AWS_DEFAULT_REGION="YOUR_PREFERRED_REGION"

# Print a confirmation message
echo "AWS credentials have been set as environmental variables."
echo "Access Key ID: $AWS_ACCESS_KEY_ID"
echo "Secret Access Key: ${AWS_SECRET_ACCESS_KEY:0:5}..."
echo "Default Region: $AWS_DEFAULT_REGION"

# Optionally, you can test the credentials
# aws sts get-caller-identity