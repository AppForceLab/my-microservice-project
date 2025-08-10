#!/bin/bash

# Database connection testing script
# This script tests connectivity to both RDS and Aurora databases

echo "🔍 Testing Database Connections..."

# Get outputs from Terraform
echo "📋 Getting database connection information..."

# PostgreSQL RDS connection test
echo "🐘 Testing PostgreSQL RDS connection..."
POSTGRES_ENDPOINT=$(terraform output -raw postgres_rds_endpoint 2>/dev/null)
POSTGRES_PORT=$(terraform output -raw postgres_rds_port 2>/dev/null)
POSTGRES_DB=$(terraform output -raw postgres_rds_database_name 2>/dev/null)

if [ ! -z "$POSTGRES_ENDPOINT" ]; then
    echo "  📍 Endpoint: $POSTGRES_ENDPOINT"
    echo "  🔌 Port: $POSTGRES_PORT"
    echo "  💾 Database: $POSTGRES_DB"
    
    # Test basic connectivity (requires psql or nc)
    if command -v nc &> /dev/null; then
        echo "  🔍 Testing network connectivity..."
        if nc -z $POSTGRES_ENDPOINT $POSTGRES_PORT; then
            echo "  ✅ Network connectivity: SUCCESS"
        else
            echo "  ❌ Network connectivity: FAILED"
        fi
    else
        echo "  ⚠️  nc (netcat) not available, skipping connectivity test"
    fi
    
    # Test with psql if available
    if command -v psql &> /dev/null; then
        echo "  🔍 Testing PostgreSQL connection with psql..."
        # Note: This requires the password to be available
        # In real scenarios, you'd use .pgpass file or environment variables
        echo "  ℹ️  To test with psql manually, use:"
        echo "     PGPASSWORD='MySecretPassword123!' psql -h $POSTGRES_ENDPOINT -p $POSTGRES_PORT -U dbadmin -d $POSTGRES_DB"
    else
        echo "  ⚠️  psql not available, install PostgreSQL client to test connectivity"
    fi
else
    echo "  ❌ PostgreSQL RDS not found in outputs"
fi

echo ""

# Aurora MySQL connection test (commented out for now)
echo "🐬 Testing Aurora MySQL connection..."
AURORA_ENDPOINT=$(terraform output -raw mysql_aurora_writer_endpoint 2>/dev/null)
AURORA_PORT=$(terraform output -raw mysql_aurora_port 2>/dev/null)
AURORA_DB=$(terraform output -raw mysql_aurora_database_name 2>/dev/null)

if [ ! -z "$AURORA_ENDPOINT" ]; then
    echo "  📍 Writer Endpoint: $AURORA_ENDPOINT"
    echo "  🔌 Port: $AURORA_PORT"
    echo "  💾 Database: $AURORA_DB"
    
    # Test basic connectivity
    if command -v nc &> /dev/null; then
        echo "  🔍 Testing network connectivity..."
        if nc -z $AURORA_ENDPOINT $AURORA_PORT; then
            echo "  ✅ Network connectivity: SUCCESS"
        else
            echo "  ❌ Network connectivity: FAILED"
        fi
    fi
    
    # Test with mysql client if available
    if command -v mysql &> /dev/null; then
        echo "  🔍 Testing MySQL connection..."
        echo "  ℹ️  To test with mysql manually, use:"
        echo "     mysql -h $AURORA_ENDPOINT -P $AURORA_PORT -u admin -p $AURORA_DB"
    else
        echo "  ⚠️  mysql client not available, install MySQL client to test connectivity"
    fi
else
    echo "  ❌ Aurora MySQL not found in outputs (likely commented out)"
fi

echo ""

# Security Groups information
echo "🔒 Security Group Information..."
POSTGRES_SG=$(terraform output -raw postgres_rds_security_group_id 2>/dev/null || echo "N/A")
echo "  🛡️  PostgreSQL Security Group: $POSTGRES_SG"

if [ "$POSTGRES_SG" != "N/A" ]; then
    echo "  📋 To check security group rules:"
    echo "     aws ec2 describe-security-groups --group-ids $POSTGRES_SG --query 'SecurityGroups[0].IpPermissions'"
fi

echo ""

# Terraform outputs summary
echo "📊 All Database Outputs:"
terraform output | grep -E "(rds|aurora|postgres|mysql)" 2>/dev/null || echo "No database outputs found"

echo ""
echo "✅ Database connection testing completed!"
echo "💡 Note: Network connectivity tests may fail if running from outside AWS VPC"
echo "💡 For actual database queries, ensure you have the correct credentials and network access"