# PATCH API Test Guide - PaymentService

## Tổng quan
Hướng dẫn này mô tả cách test PATCH API để update dữ liệu PolicyAccount trong PaymentService.

## PATCH API Endpoint
```
PATCH /api/account/{id}
```

## Cách test PATCH API

### 1. Chuẩn bị dữ liệu test

Trước tiên, tạo một account để test:

```http
POST http://localhost:5001/api/account
Content-Type: application/json

{
    "policyNumber": "POL-001",
    "policyAccountNumber": "ACC-001",
    "ownerName": "Nguyen Van A",
    "balance": 1000.00
}
```

Lưu lại `id` của account được tạo để sử dụng trong PATCH request.

### 2. Test PATCH API - Update toàn bộ thông tin

```http
PATCH http://localhost:5001/api/account/{id}
Content-Type: application/json

{
    "policyNumber": "POL-001-UPDATED",
    "policyAccountNumber": "ACC-001-UPDATED", 
    "ownerName": "Nguyen Van A Updated",
    "balance": 2000.00
}
```

### 3. Test PATCH API - Update một phần thông tin

```http
PATCH http://localhost:5001/api/account/{id}
Content-Type: application/json

{
    "policyNumber": "POL-001",
    "policyAccountNumber": "ACC-001",
    "ownerName": "Nguyen Van A",
    "balance": 1500.00
}
```

### 4. Test cases cần kiểm tra

#### 4.1 Test thành công
- Update với ID hợp lệ
- Update tất cả fields
- Update chỉ một số fields
- Kiểm tra response trả về đúng dữ liệu đã update

#### 4.2 Test lỗi
- Update với ID không tồn tại
- Update với ID không hợp lệ (format sai)
- Update với dữ liệu không hợp lệ

### 5. Ví dụ test cases chi tiết

#### Test Case 1: Update thành công
```http
PATCH http://localhost:5001/api/account/550e8400-e29b-41d4-a716-446655440000
Content-Type: application/json

{
    "policyNumber": "POL-UPDATED",
    "policyAccountNumber": "ACC-UPDATED",
    "ownerName": "Updated Owner",
    "balance": 5000.00
}
```

**Expected Response:**
```json
{
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "policyNumber": "POL-UPDATED",
    "policyAccountNumber": "ACC-UPDATED", 
    "ownerName": "Updated Owner",
    "balance": 5000.00
}
```

#### Test Case 2: ID không tồn tại
```http
PATCH http://localhost:5001/api/account/00000000-0000-0000-0000-000000000000
Content-Type: application/json

{
    "policyNumber": "POL-001",
    "policyAccountNumber": "ACC-001",
    "ownerName": "Test User",
    "balance": 1000.00
}
```

**Expected Response:**
```
404 Not Found
"Account with ID 00000000-0000-0000-0000-000000000000 not found"
```

#### Test Case 3: ID format không hợp lệ
```http
PATCH http://localhost:5001/api/account/invalid-id
Content-Type: application/json

{
    "policyNumber": "POL-001",
    "policyAccountNumber": "ACC-001", 
    "ownerName": "Test User",
    "balance": 1000.00
}
```

**Expected Response:**
```
400 Bad Request
```

### 6. Workflow test hoàn chỉnh

1. **Tạo account mới:**
   ```http
   POST http://localhost:5001/api/account
   ```

2. **Lấy danh sách accounts để xem ID:**
   ```http
   GET http://localhost:5001/api/account
   ```

3. **Update account với PATCH:**
   ```http
   PATCH http://localhost:5001/api/account/{id}
   ```

4. **Verify update thành công:**
   ```http
   GET http://localhost:5001/api/account/{policyNumber}
   ```

### 7. Tools để test

#### 7.1 Sử dụng VS Code REST Client
Tạo file `.http` với các request trên và chạy trực tiếp trong VS Code.

#### 7.2 Sử dụng Postman
Import các request vào Postman collection để test.

#### 7.3 Sử dụng curl
```bash
curl -X PATCH "http://localhost:5001/api/account/{id}" \
     -H "Content-Type: application/json" \
     -d '{
       "policyNumber": "POL-UPDATED",
       "policyAccountNumber": "ACC-UPDATED",
       "ownerName": "Updated Owner", 
       "balance": 5000.00
     }'
```

### 8. Lưu ý quan trọng

- Đảm bảo PaymentService đang chạy trên port 5001
- Kiểm tra database connection trước khi test
- PATCH API sẽ update toàn bộ object, không phải partial update
- Luôn kiểm tra response status code và message
- Test cả happy path và error cases

### 9. Troubleshooting

#### Lỗi thường gặp:
- **404 Not Found**: ID không tồn tại trong database
- **400 Bad Request**: Dữ liệu request không hợp lệ
- **500 Internal Server Error**: Lỗi server, kiểm tra logs

#### Debug tips:
- Kiểm tra logs trong console để xem query được thực thi
- Verify ID format là GUID hợp lệ
- Đảm bảo Content-Type header đúng