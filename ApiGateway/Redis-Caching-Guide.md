# Redis Caching Configuration Guide

## Tổng quan
API Gateway đã được cấu hình để sử dụng Redis làm distributed cache thay cho in-memory cache mặc định. Điều này cải thiện performance và hỗ trợ scaling horizontal.

## Redis Configuration

### 1. Connection Settings
```json
{
  "ConnectionStrings": {
    "Redis": "localhost:6379"
  },
  "RedisSettings": {
    "ConnectionString": "localhost:6379",
    "Database": 0,
    "InstanceName": "ApiGateway"
  }
}
```

### 2. Cache Regions và TTL
Mỗi endpoint có cache configuration riêng:

| Endpoint | TTL | Region | Lý do |
|----------|-----|--------|-------|
| `/pricing` | 30s | pricing | Data thay đổi thường xuyên |
| `/pricing/{id}` | 60s | pricing-details | Chi tiết ít thay đổi hơn |
| `/policy` | 120s | policy | Data ổn định, ít thay đổi |

### 3. Cache Keys
Redis sử dụng cache keys dựa trên:
- Route template
- Query parameters  
- Path parameters
- Headers (nếu cấu hình)

Ví dụ cache keys:
```
pricing:GET:/pricing
pricing-details:GET:/pricing/123
pricing-details:GET:/pricing/456
policy:GET:/policy
```

## Benefits của Redis Caching

### 1. Performance Improvements
- **Reduced latency**: Cached responses trả về nhanh hơn
- **Reduced load**: Giảm tải cho downstream services
- **Better user experience**: Response time nhanh và ổn định

### 2. Scalability
- **Distributed caching**: Multiple API Gateway instances share cache
- **Horizontal scaling**: Cache không bị mất khi restart services
- **Memory efficiency**: Cache được lưu ở Redis, không chiếm RAM của API Gateway

### 3. Reliability
- **Persistence**: Redis có thể persist data to disk
- **High availability**: Redis cluster/sentinel support
- **Monitoring**: Redis có tools monitoring tốt

## Cache Strategy

### 1. Cache-Aside Pattern
API Gateway sử dụng cache-aside pattern:
1. Check cache first
2. If miss, call downstream service
3. Store result in cache
4. Return response

### 2. TTL Strategy
- **Short TTL** (30s): Cho data thay đổi thường xuyên
- **Medium TTL** (60s): Cho data ổn định hơn
- **Long TTL** (120s): Cho data ít thay đổi

### 3. Cache Invalidation
- **Time-based**: Automatic expiration với TTL
- **Manual**: Có thể clear cache qua Redis CLI
- **Event-based**: Có thể integrate với message queues

## Installation & Setup

### 1. Local Development
```bash
# Install Redis
brew install redis  # macOS
# hoặc
sudo apt-get install redis-server  # Ubuntu

# Start Redis
redis-server

# Test connection
redis-cli ping
```

### 2. Docker Development
```bash
# Start với docker-compose
docker-compose up redis

# Test connection
docker exec -it redis-cache redis-cli ping
```

### 3. Production
- Sử dụng Redis cluster cho high availability
- Configure persistence (RDB + AOF)
- Set up monitoring (Redis Insight, Prometheus)
- Configure memory policies

## Testing Redis Caching

### 1. Automated Testing
```bash
./test-redis-caching.sh
```

### 2. Manual Testing với HTTP file
1. Mở `test-redis-caching.http`
2. Lấy JWT token
3. Test các endpoints và so sánh response time

### 3. Redis CLI Commands
```bash
# View all keys
redis-cli keys "*"

# Check TTL
redis-cli ttl "pricing:GET:/pricing"

# View cached value
redis-cli get "pricing:GET:/pricing"

# Clear all cache
redis-cli flushall

# Monitor Redis operations
redis-cli monitor
```

## Monitoring & Debugging

### 1. Cache Hit/Miss Monitoring
```bash
# Monitor Redis operations
redis-cli monitor

# Check cache statistics
redis-cli info stats
```

### 2. Performance Metrics
- Response time comparison (cached vs non-cached)
- Cache hit ratio
- Memory usage
- Network traffic reduction

### 3. Debugging Cache Issues
```bash
# Check if key exists
redis-cli exists "pricing:GET:/pricing"

# Check key TTL
redis-cli ttl "pricing:GET:/pricing"

# View key content
redis-cli get "pricing:GET:/pricing"

# Check Redis logs
docker logs redis-cache
```

## Configuration Options

### 1. CacheManager Configuration
```csharp
var configuration = ConfigurationBuilder.New()
    .WithUpdateMode(CacheUpdateMode.Up)
    .WithSerializer(typeof(JsonCacheSerializer))
    .WithRedis(config =>
    {
        config.WithEndpoint(redisConnectionString);
        config.WithDatabase(0);
    })
    .Build();
```

### 2. Ocelot Cache Options
```json
{
  "FileCacheOptions": {
    "TtlSeconds": 30,
    "Region": "pricing"
  }
}
```

### 3. Redis Connection Options
- **ConnectionString**: Redis server address
- **Database**: Redis database number (0-15)
- **Password**: Redis authentication
- **SSL**: Secure connection
- **ConnectTimeout**: Connection timeout
- **SyncTimeout**: Operation timeout

## Best Practices

### 1. Cache Key Design
- Use meaningful prefixes
- Include version in keys if needed
- Avoid very long keys
- Use consistent naming convention

### 2. TTL Strategy
- Set appropriate TTL based on data volatility
- Use shorter TTL for frequently changing data
- Consider business requirements

### 3. Memory Management
- Monitor Redis memory usage
- Set maxmemory policy
- Use appropriate data structures
- Clean up expired keys

### 4. Security
- Use Redis AUTH
- Configure network security
- Encrypt sensitive cached data
- Use SSL/TLS for connections

## Troubleshooting

### 1. Connection Issues
```bash
# Test Redis connection
redis-cli ping

# Check Redis status
redis-cli info server
```

### 2. Cache Not Working
- Check Redis connection string
- Verify cache configuration in ocelot.json
- Check API Gateway logs
- Verify TTL settings

### 3. Performance Issues
- Monitor Redis memory usage
- Check network latency
- Optimize cache key design
- Consider Redis clustering

### 4. Data Consistency
- Understand cache invalidation strategy
- Monitor cache hit/miss ratio
- Consider cache warming strategies
- Plan for cache failures

## Production Considerations

### 1. High Availability
- Redis Sentinel for automatic failover
- Redis Cluster for horizontal scaling
- Multiple Redis instances
- Load balancing

### 2. Persistence
- RDB snapshots for point-in-time recovery
- AOF for durability
- Backup strategies
- Disaster recovery plans

### 3. Monitoring
- Redis metrics (memory, connections, operations)
- Cache hit/miss ratios
- Response time improvements
- Error rates and alerts

### 4. Scaling
- Horizontal scaling with Redis Cluster
- Vertical scaling with more memory
- Connection pooling
- Partitioning strategies