#!/bin/bash

# AWS Resources checking script
# This script checks the actual AWS resources created by our Terraform

echo "🔍 Checking AWS Resources created by Terraform..."

REGION="eu-west-1"
PROJECT_NAME="lesson-db-module"

echo "🌍 Region: $REGION"
echo "📋 Project: $PROJECT_NAME"
echo ""

# Check RDS Instances
echo "🗄️  RDS Instances:"
aws rds describe-db-instances \
    --region $REGION \
    --query 'DBInstances[?contains(DBInstanceIdentifier, `lesson-db-module`)].{ID:DBInstanceIdentifier,Engine:Engine,Status:DBInstanceStatus,Endpoint:Endpoint.Address,Port:Endpoint.Port}' \
    --output table 2>/dev/null || echo "No RDS instances found or AWS CLI error"

echo ""

# Check RDS Clusters (Aurora)
echo "🌟 Aurora Clusters:"
aws rds describe-db-clusters \
    --region $REGION \
    --query 'DBClusters[?contains(DBClusterIdentifier, `lesson-db-module`)].{ID:DBClusterIdentifier,Engine:Engine,Status:Status,Endpoint:Endpoint,ReaderEndpoint:ReaderEndpoint}' \
    --output table 2>/dev/null || echo "No Aurora clusters found or AWS CLI error"

echo ""

# Check DB Subnet Groups
echo "🌐 DB Subnet Groups:"
aws rds describe-db-subnet-groups \
    --region $REGION \
    --query 'DBSubnetGroups[?contains(DBSubnetGroupName, `lesson-db-module`)].{Name:DBSubnetGroupName,VPC:VpcId,Subnets:length(Subnets)}' \
    --output table 2>/dev/null || echo "No DB subnet groups found or AWS CLI error"

echo ""

# Check Security Groups
echo "🛡️  Security Groups:"
aws ec2 describe-security-groups \
    --region $REGION \
    --filters "Name=group-name,Values=*lesson-db-module*" \
    --query 'SecurityGroups[].{Name:GroupName,ID:GroupId,VPC:VpcId,Description:Description}' \
    --output table 2>/dev/null || echo "No security groups found or AWS CLI error"

echo ""

# Check Parameter Groups
echo "⚙️  DB Parameter Groups:"
aws rds describe-db-parameter-groups \
    --region $REGION \
    --query 'DBParameterGroups[?contains(DBParameterGroupName, `lesson-db-module`)].{Name:DBParameterGroupName,Family:DBParameterGroupFamily,Description:Description}' \
    --output table 2>/dev/null || echo "No parameter groups found or AWS CLI error"

echo ""

# Check Cluster Parameter Groups
echo "🎛️  Cluster Parameter Groups:"
aws rds describe-db-cluster-parameter-groups \
    --region $REGION \
    --query 'DBClusterParameterGroups[?contains(DBClusterParameterGroupName, `lesson-db-module`)].{Name:DBClusterParameterGroupName,Family:DBParameterGroupFamily,Description:Description}' \
    --output table 2>/dev/null || echo "No cluster parameter groups found or AWS CLI error"

echo ""

# Check VPC and Subnets
echo "🏗️  VPC Resources:"
VPC_ID=$(aws ec2 describe-vpcs --region $REGION --filters "Name=tag:Name,Values=lesson-*-vpc" --query 'Vpcs[0].VpcId' --output text 2>/dev/null)

if [ "$VPC_ID" != "None" ] && [ "$VPC_ID" != "" ]; then
    echo "📍 VPC ID: $VPC_ID"
    
    # Count subnets
    SUBNET_COUNT=$(aws ec2 describe-subnets --region $REGION --filters "Name=vpc-id,Values=$VPC_ID" --query 'length(Subnets)' --output text 2>/dev/null)
    echo "🌐 Subnets in VPC: $SUBNET_COUNT"
else
    echo "❌ VPC not found"
fi

echo ""

# Check EKS Cluster
echo "☸️  EKS Clusters:"
aws eks describe-cluster \
    --region $REGION \
    --name lesson-8-9-eks-cluster \
    --query 'cluster.{Name:name,Status:status,Endpoint:endpoint,Version:version}' \
    --output table 2>/dev/null || echo "EKS cluster not found or not ready yet"

echo ""

# Summary
echo "📊 Resource Summary:"
echo "=================="

# Count resources by type
RDS_COUNT=$(aws rds describe-db-instances --region $REGION --query 'length(DBInstances[?contains(DBInstanceIdentifier, `lesson-db-module`)])' --output text 2>/dev/null || echo "0")
AURORA_COUNT=$(aws rds describe-db-clusters --region $REGION --query 'length(DBClusters[?contains(DBClusterIdentifier, `lesson-db-module`)])' --output text 2>/dev/null || echo "0")
SG_COUNT=$(aws ec2 describe-security-groups --region $REGION --filters "Name=group-name,Values=*lesson-db-module*" --query 'length(SecurityGroups)' --output text 2>/dev/null || echo "0")

echo "🗄️  RDS Instances: $RDS_COUNT"
echo "🌟 Aurora Clusters: $AURORA_COUNT"
echo "🛡️  Database Security Groups: $SG_COUNT"

if [ "$RDS_COUNT" -gt 0 ] || [ "$AURORA_COUNT" -gt 0 ]; then
    echo "✅ Database resources are being created/available"
else
    echo "⏳ Database resources are still being created or not found"
fi

echo ""
echo "🔄 To monitor creation progress:"
echo "   terraform apply (check in another terminal)"
echo "   terraform show (after completion)"
echo "   terraform output (to see connection details)"

echo ""
echo "💡 Note: Resources may take 10-20 minutes to fully provision"