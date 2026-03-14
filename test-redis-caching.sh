#!/bin/bash

echo "=========================================="
echo "Redis Caching Test Script"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Redis is running
echo -e "\n${YELLOW}Step 1: Checking Redis connection${NC}"
if command -v redis-cli &> /dev/null; then
    redis_status=$(redis-cli ping 2>/dev/null)
    if [ "$redis_status" = "PONG" ]; then
        echo -e "${GREEN}✓ Redis is running${NC}"
    else
        echo -e "${RED}✗ Redis is not responding${NC}"
        echo "Please start Redis: redis-server"
        exit 1
    fi
else
    echo -e "${YELLOW}⚠ redis-cli not found. Assuming Redis is running...${NC}"
fi

# Get JWT Token
echo -e "\n${YELLOW}Step 2: Getting JWT Token${NC}"
TOKEN_RESPONSE=$(curl -s -X POST "http://localhost:5050/auth/generate-token" \
    -H "Content-Type: application/json" \
    -H "ClientId: cache-test" \
    -d '{"username":"testuser"}')

if command -v jq &> /dev/null; then
    TOKEN=$(echo "$TOKEN_RESPONSE" | jq -r '.token')
    echo "Token obtained: ${TOKEN:0:50}..."
else
    TOKEN=$(echo "$TOKEN_RESPONSE" | sed -n 's/.*"token":"\([^"]*\)".*/\1/p')
    echo "Token obtained: ${TOKEN:0:50}..."
fi

if [ "$TOKEN" = "null" ] || [ -z "$TOKEN" ]; then
    echo -e "${RED}Failed to get token. Exiting.${NC}"
    exit 1
fi

# Function to measure response time
measure_response_time() {
    local url=$1
    local headers=$2
    local description=$3
    
    echo -e "\n${BLUE}Testing: $description${NC}"
    
    # First request
    echo -n "First request (should hit downstream): "
    start_time=$(date +%s%N)
    response1=$(curl -s -w "%{http_code}" $headers "$url")
    end_time=$(date +%s%N)
    time1=$(( (end_time - start_time) / 1000000 ))
    status1="${response1: -3}"
    
    echo "Status: $status1, Time: ${time1}ms"
    
    # Small delay
    sleep 0.5
    
    # Second request (should be cached)
    echo -n "Second request (should be from cache): "
    start_time=$(date +%s%N)
    response2=$(curl -s -w "%{http_code}" $headers "$url")
    end_time=$(date +%s%N)
    time2=$(( (end_time - start_time) / 1000000 ))
    status2="${response2: -3}"
    
    echo "Status: $status2, Time: ${time2}ms"
    
    # Compare response times
    if [ "$time2" -lt "$time1" ]; then
        echo -e "${GREEN}✓ Cache working! Second request was faster (${time1}ms → ${time2}ms)${NC}"
    elif [ "$status1" = "$status2" ] && [ "$status1" != "404" ]; then
        echo -e "${YELLOW}? Same response time. Cache may be working but response times are similar${NC}"
    else
        echo -e "${RED}✗ Cache may not be working or services not available${NC}"
    fi
}

# Test caching for different endpoints
echo -e "\n${YELLOW}Step 3: Testing Redis Caching${NC}"

# Test Pricing endpoint (30s cache)
measure_response_time "http://localhost:5050/pricing" \
    "-H 'Authorization: Bearer $TOKEN' -H 'ClientId: cache-test-pricing'" \
    "Pricing endpoint (30s cache)"

# Test Pricing by ID endpoint (60s cache)
measure_response_time "http://localhost:5050/pricing/123" \
    "-H 'Authorization: Bearer $TOKEN' -H 'ClientId: cache-test-details'" \
    "Pricing by ID endpoint (60s cache)"

# Test Policy endpoint (120s cache)
measure_response_time "http://localhost:5050/policy" \
    "-H 'Authorization: Bearer $TOKEN' -H 'ClientId: cache-test-policy'" \
    "Policy endpoint (120s cache)"

# Check Redis keys if redis-cli is available
if command -v redis-cli &> /dev/null; then
    echo -e "\n${YELLOW}Step 4: Checking Redis Cache Keys${NC}"
    echo "Current Redis keys:"
    redis_keys=$(redis-cli keys "*" 2>/dev/null)
    if [ -n "$redis_keys" ]; then
        echo "$redis_keys" | while read -r key; do
            if [ -n "$key" ]; then
                ttl=$(redis-cli ttl "$key" 2>/dev/null)
                echo "  $key (TTL: ${ttl}s)"
            fi
        done
    else
        echo "  No keys found in Redis"
    fi
fi

echo -e "\n=========================================="
echo -e "${GREEN}Redis Caching Test Complete!${NC}"
echo "=========================================="
echo -e "${YELLOW}Cache Configuration:${NC}"
echo "• Pricing GET: 30 seconds TTL, region 'pricing'"
echo "• Pricing GET by ID: 60 seconds TTL, region 'pricing-details'"
echo "• Policy GET: 120 seconds TTL, region 'policy'"
echo ""
echo -e "${BLUE}Notes:${NC}"
echo "• First requests hit downstream services (slower)"
echo "• Subsequent requests served from Redis cache (faster)"
echo "• 404 errors are expected if services aren't running"
echo "• The important thing is response time improvement"