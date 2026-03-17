#!/bin/bash

echo "=== Hướng dẫn chạy API Find Account by PolicyNumber ==="
echo ""

echo "1. Khởi động PaymentService:"
echo "   cd PaymentService"
echo "   dotnet run"
echo ""

echo "2. Mở terminal khác và test API:"
echo ""

echo "   a) Tạo test account:"
echo '   curl -X POST "https://localhost:7001/api/account" \'
echo '     -H "Content-Type: application/json" \'
echo '     -d '"'"'{"policyNumber": "POL001", "policyAccountNumber": "ACC001", "balance": 1000.50}'"'"' \'
echo '     -k'
echo ""

echo "   b) Tìm account theo PolicyNumber:"
echo '   curl -X GET "https://localhost:7001/api/account/POL001" \'
echo '     -H "Accept: application/json" \'
echo '     -k'
echo ""

echo "   c) Test trường hợp không tìm thấy:"
echo '   curl -X GET "https://localhost:7001/api/account/POL999" \'
echo '     -H "Accept: application/json" \'
echo '     -k'
echo ""

echo "3. Hoặc sử dụng file test-find-account.http trong VS Code với REST Client extension"
echo ""

echo "=== API Endpoints ==="
echo "GET /api/account/{policyNumber}     - Tìm account theo PolicyNumber (Controller)"
echo "GET /policy-accounts/{policyNumber} - Tìm account theo PolicyNumber (Minimal API)"
echo "POST /api/account                   - Tạo account mới (Controller)"
echo "POST /policy-accounts               - Tạo account mới (Minimal API)"
echo ""

echo "=== Lưu ý ==="
echo "- Đảm bảo PostgreSQL đang chạy"
echo "- Service chạy trên https://localhost:7001"
echo "- Sử dụng -k với curl để bỏ qua SSL certificate"
echo "- API đã có error handling đầy đủ"