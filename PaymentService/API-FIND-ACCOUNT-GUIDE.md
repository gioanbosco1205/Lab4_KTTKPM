# Hướng dẫn API Tìm Account theo PolicyNumber

## Mô tả
API này cho phép tìm kiếm account theo PolicyNumber trong PaymentService.

## Endpoints có sẵn

### 1. Controller API (Khuyến nghị sử dụng)
```
GET /api/account/{policyNumber}
```

### 2. Minimal API (Thay thế)
```
GET /policy-accounts/{policyNumber}
```

## Cách chạy và test

### Bước 1: Khởi động PaymentService
```bash
cd PaymentService
dotnet run
```

Service sẽ chạy trên: `https://localhost:7001` hoặc `http://localhost:5001`

### Bước 2: Tạo test data (nếu chưa có)
Sử dụng POST để tạo account mẫu:

**Controller API:**
```http
POST https://localhost:7001/api/account
Content-Type: application/json

{
    "policyNumber": "POL001",
    "policyAccountNumber": "ACC001",
    "ownerName": "Nguyen Van A",
    "balance": 1000.50
}
```

**Minimal API:**
```http
POST https://localhost:7001/policy-accounts
Content-Type: application/json

{
    "policyNumber": "POL002", 
    "policyAccountNumber": "ACC002",
    "ownerName": "Tran Thi B",
    "balance": 2000.75
}
```

### Bước 3: Test API tìm account

**Controller API (Khuyến nghị):**
```http
GET https://localhost:7001/api/account/POL001
```

**Minimal API:**
```http
GET https://localhost:7001/policy-accounts/POL002
```

## Response mẫu

### Thành công (200 OK):
```json
{
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "policyNumber": "POL001",
    "policyAccountNumber": "ACC001",
    "ownerName": "Nguyen Van A", 
    "balance": 1000.50
}
```

### Không tìm thấy (404 Not Found):
```json
{
    "type": "https://tools.ietf.org/html/rfc7231#section-6.5.4",
    "title": "Not Found",
    "status": 404,
    "detail": "Account with policy number POL999 not found"
}
```

### Lỗi server (400 Bad Request):
```json
{
    "type": "https://tools.ietf.org/html/rfc7231#section-6.5.1", 
    "title": "Bad Request",
    "status": 400,
    "detail": "Error retrieving account: [error message]"
}
```

## Test với curl

### Tạo account:
```bash
curl -X POST "https://localhost:7001/api/account" \
  -H "Content-Type: application/json" \
  -d '{
    "policyNumber": "POL001",
    "policyAccountNumber": "ACC001",
    "ownerName": "Nguyen Van A", 
    "balance": 1000.50
  }' \
  -k
```

### Tìm account:
```bash
curl -X GET "https://localhost:7001/api/account/POL001" \
  -H "Accept: application/json" \
  -k
```

## Lưu ý quan trọng

1. **Database**: Đảm bảo PostgreSQL đang chạy và connection string đúng
2. **HTTPS**: Sử dụng `-k` flag với curl để bỏ qua SSL certificate validation
3. **Case sensitive**: PolicyNumber có phân biệt hoa thường
4. **Error handling**: API đã có xử lý lỗi đầy đủ, không nên xảy ra exception

## Troubleshooting

### Nếu gặp lỗi database:
1. Kiểm tra PostgreSQL đang chạy
2. Test connection: `GET /test-db`
3. Tạo schema: `POST /create-schema`
4. Kiểm tra tables: `GET /check-tables`

### Nếu 404 Not Found:
- Đảm bảo đã tạo account với PolicyNumber đó trước
- Kiểm tra chính tả PolicyNumber