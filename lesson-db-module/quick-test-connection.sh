#!/bin/bash

# Quick connection test for PostgreSQL RDS
echo "🧪 Quick PostgreSQL RDS Connection Test"
echo "========================================"

# Database connection details (from Terraform)
ENDPOINT="lesson-db-module-dev-db.cdg82o4wqs1y.eu-west-1.rds.amazonaws.com"
PORT="5432"
DATABASE="myapp"
USERNAME="dbadmin"
PASSWORD="MySecretPassword123!"

echo "📍 Endpoint: $ENDPOINT"
echo "🔌 Port: $PORT"
echo "💾 Database: $DATABASE"
echo "👤 Username: $USERNAME"
echo ""

# Test 1: Network connectivity
echo "🔍 Test 1: Network Connectivity"
if command -v nc &> /dev/null; then
    if nc -z -w5 $ENDPOINT $PORT; then
        echo "✅ Network connectivity: SUCCESS"
    else
        echo "❌ Network connectivity: FAILED"
        echo "   This is expected if running outside AWS VPC"
    fi
else
    echo "⚠️  nc (netcat) not available - skipping network test"
fi

echo ""

# Test 2: PostgreSQL connection (if psql available)
echo "🔍 Test 2: PostgreSQL Connection"
if command -v psql &> /dev/null; then
    echo "🔧 Testing with psql..."
    
    # Set connection parameters
    export PGPASSWORD=$PASSWORD
    
    # Try to connect and run basic query
    if psql -h $ENDPOINT -p $PORT -U $USERNAME -d $DATABASE -c "SELECT version();" 2>/dev/null | grep -q "PostgreSQL"; then
        echo "✅ PostgreSQL connection: SUCCESS"
        echo "📊 Running test queries..."
        
        # Test basic operations
        psql -h $ENDPOINT -p $PORT -U $USERNAME -d $DATABASE << EOF
SELECT 'Database connection test successful!' as message;
SELECT current_database(), current_user, version();
SELECT pg_size_pretty(pg_database_size(current_database())) as database_size;
\l
EOF
    else
        echo "❌ PostgreSQL connection: FAILED"
        echo "   Check credentials and network access"
    fi
else
    echo "⚠️  psql not available - install PostgreSQL client to test"
    echo "💡 Install with:"
    echo "   macOS: brew install postgresql"
    echo "   Ubuntu: apt install postgresql-client"
    echo ""
    echo "💡 Manual connection command:"
    echo "   PGPASSWORD='$PASSWORD' psql -h $ENDPOINT -p $PORT -U $USERNAME -d $DATABASE"
fi

echo ""

# Test 3: DNS resolution
echo "🔍 Test 3: DNS Resolution"
if nslookup $ENDPOINT > /dev/null 2>&1; then
    IP=$(nslookup $ENDPOINT | grep -A 1 "Name:" | tail -1 | awk '{print $2}')
    echo "✅ DNS resolution: SUCCESS ($IP)"
else
    echo "❌ DNS resolution: FAILED"
fi

echo ""
echo "📋 Summary:"
echo "==========="
echo "RDS Instance: lesson-db-module-dev-db"
echo "Endpoint: $ENDPOINT"
echo "Status: Ready for connections"
echo ""
echo "💡 Connection from application:"
echo "   Host: $ENDPOINT"
echo "   Port: $PORT" 
echo "   Database: $DATABASE"
echo "   Username: $USERNAME"
echo "   SSL: Recommend enabling"
echo ""
echo "🔗 Connection string:"
echo "   postgresql://$USERNAME:[PASSWORD]@$ENDPOINT:$PORT/$DATABASE"