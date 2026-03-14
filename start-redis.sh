#!/bin/bash

echo "=========================================="
echo "Starting Redis for API Gateway Caching"
echo "=========================================="

# Check if Redis is installed
if command -v redis-server &> /dev/null; then
    echo "✓ Redis is installed"
    
    # Check if Redis is already running
    if pgrep redis-server > /dev/null; then
        echo "⚠ Redis is already running"
        echo "Current Redis processes:"
        ps aux | grep redis-server | grep -v grep
    else
        echo "Starting Redis server..."
        redis-server --daemonize yes --appendonly yes
        sleep 2
        
        # Test connection
        if redis-cli ping > /dev/null 2>&1; then
            echo "✓ Redis started successfully"
            echo "Redis is running on localhost:6379"
        else
            echo "✗ Failed to start Redis"
            exit 1
        fi
    fi
    
    # Show Redis info
    echo ""
    echo "Redis Information:"
    echo "- Version: $(redis-cli info server | grep redis_version | cut -d: -f2 | tr -d '\r')"
    echo "- Port: 6379"
    echo "- Database: 0"
    echo "- Persistence: AOF enabled"
    
    echo ""
    echo "Useful Redis commands:"
    echo "- Test connection: redis-cli ping"
    echo "- View all keys: redis-cli keys '*'"
    echo "- Monitor operations: redis-cli monitor"
    echo "- Clear all cache: redis-cli flushall"
    echo "- Stop Redis: redis-cli shutdown"
    
elif command -v docker &> /dev/null; then
    echo "Redis not installed locally, but Docker is available"
    echo "Starting Redis with Docker..."
    
    # Check if Redis container is already running
    if docker ps | grep redis-cache > /dev/null; then
        echo "⚠ Redis container is already running"
    else
        docker run -d --name redis-cache -p 6379:6379 redis:7-alpine redis-server --appendonly yes
        sleep 3
        
        # Test connection
        if docker exec redis-cache redis-cli ping > /dev/null 2>&1; then
            echo "✓ Redis container started successfully"
            echo "Redis is running on localhost:6379"
        else
            echo "✗ Failed to start Redis container"
            exit 1
        fi
    fi
    
    echo ""
    echo "Docker Redis commands:"
    echo "- Test connection: docker exec redis-cache redis-cli ping"
    echo "- View keys: docker exec redis-cache redis-cli keys '*'"
    echo "- Monitor: docker exec redis-cache redis-cli monitor"
    echo "- Stop container: docker stop redis-cache"
    
else
    echo "✗ Neither Redis nor Docker is installed"
    echo ""
    echo "Please install Redis:"
    echo "- macOS: brew install redis"
    echo "- Ubuntu: sudo apt-get install redis-server"
    echo "- Or use Docker: docker run -d -p 6379:6379 redis:7-alpine"
    exit 1
fi

echo ""
echo "=========================================="
echo "Redis is ready for API Gateway caching!"
echo "=========================================="