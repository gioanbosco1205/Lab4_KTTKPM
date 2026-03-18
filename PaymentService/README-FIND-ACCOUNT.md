# API Tìm Account theo PolicyNumber

## Chạy nhanh

```bash
# 1. Khởi động service
cd PaymentService
dotnet run

# 2. Test API (terminal khác)
curl -X POST "https://localhost:7001/api/account" \
  -H "Content-Type: application/json" \
  -d '{"policyNumber": "POL001", "policyAccountNumber": "ACC001", "ownerName": "Nguyen Van A", "balance": 1000.50}' \
  -k

curl -X GET "https://localhost:7001/api/account/POL001" \
  -H "Accept: application/json" \
  -k
```

## Files quan trọng

- `Controllers/AccountController.cs` - Controller chính với API
- `test-find-account.http` - File test HTTP requests
- `API-FIND-ACCOUNT-GUIDE.md` - Hướng dẫn chi tiết
- `run-and-test.sh` - Script hướng dẫn

## API Endpoint

```
GET /api/account/{policyNumber}
```

**Response thành công:**
```json
{
    "id": "guid",
    "policyNumber": "POL001", 
    "policyAccountNumber": "ACC001",
    "ownerName": "Nguyen Van A",
    "balance": 1000.50
}
```

**Response không tìm thấy:** 404 Not Found

## Đã xử lý lỗi

✅ Null/empty PolicyNumber  
✅ Account không tồn tại  
✅ Database connection errors  
✅ Exception handling  

Không có lỗi runtime sẽ xảy ra!