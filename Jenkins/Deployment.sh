#!/bin/bash

# Retrieve the AWS region from the AWS CLI configuration
aws_region=$(aws configure get region)

# Use the AWS CLI to get the EKS cluster name based on the configured region
eks_cluster_name=$(aws eks list-clusters --region "$aws_region" --output json | jq -r '.clusters[0]')

# Check if the cluster name is empty
if [ -z "$eks_cluster_name" ]; then
  echo "Unable to retrieve the EKS cluster name. Make sure you have configured the AWS CLI and have access to at least one EKS cluster in the specified region."
  exit 1
fi

# Check if kubectl is installed
if ! command -v kubectl &>/dev/null; then
  echo "kubectl not found. Please install kubectl first."
  exit 1
fi

# Check if AWS CLI is configured
if ! aws configure get aws_access_key_id &>/dev/null; then
  echo "AWS CLI is not configured. Please run 'aws configure' to set up your AWS credentials."
  exit 1
fi

# Configure kubectl for EKS cluster
aws eks update-kubeconfig --name "$eks_cluster_name" --region "$aws_region"

if [ $? -eq 0 ]; then
  echo "kubectl is now configured to use the EKS cluster: $eks_cluster_name in region: $aws_region"
else
  echo "Error configuring kubectl for EKS cluster: $eks_cluster_name in region: $aws_region"
  exit 1
fi
