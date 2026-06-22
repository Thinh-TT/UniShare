# UniShare — Hướng dẫn chạy API (Docker + ngrok) & Build APK

## Yêu cầu

- **Docker Desktop** đã cài và đang chạy
- **SQL Server** đang chạy trên máy host (localhost:1433)
- **Flutter SDK** + Android SDK (để build APK)
- **Tài khoản ngrok** (miễn phí) — lấy auth token tại https://dashboard.ngrok.com/get-started/your-authtoken

---

## 1. Chạy API với Docker + ngrok

### 1.1. Set ngrok auth token

Dán ngrok auth token vào file `.env.example`
Remane file `.env.example` thành `.env`

### 1.2. Build và start containers

```bash
cd E:\UniShare
docker compose up -d --build
```

Lần đầu build sẽ mất vài phút để tải .NET SDK image. Các lần sau nhanh hơn nhờ Docker layer caching.

### 1.3. Lấy ngrok URL

```bash
docker logs unishare-ngrok
```

Tìm dòng có dạng:

```
ngrok ...... url=https://xxxx-xxx-xxx.ngrok-free.app
```

Hoặc kiểm tra trên web dashboard: https://dashboard.ngrok.com/endpoints

Ví dụ URL: `https://abc123-def-456.ngrok-free.app`

### 1.4. Kiểm tra API hoạt động

```bash
# Qua localhost
curl http://localhost:5056/swagger/v1/swagger.json

# Qua ngrok (public)
curl https://<ngrok-domain>/swagger/v1/swagger.json
```

Swagger UI có thể truy cập tại:

- Local: http://localhost:5056/swagger
- Public: https://<ngrok-domain>/swagger

### 1.5. Quản lý containers

```bash
# Xem trạng thái
docker compose ps

# Xem logs API
docker logs unishare-api

# Dừng
docker compose down

# Restart API (sau khi sửa config)
docker compose restart api
```

---

## 2. Build APK với ngrok URL

### 2.1. Cập nhật CORS (nếu cần test Swagger qua ngrok)

Sửa file `UniShare.API/appsettings.Docker.json`, thay `https://<your-ngrok-domain>` bằng ngrok URL thực tế:

```json
"Cors": {
  "AllowedOrigins": [
    "http://localhost:*",
    "http://10.0.2.2:*",
    "http://127.0.0.1:*",
    "https://abc123-def-456.ngrok-free.app"
  ]
}
```

Sau đó restart API:

```bash
docker compose restart api
```

> **Lưu ý:** Mobile app (Flutter) không bị ảnh hưởng bởi CORS. Bước này chỉ cần nếu muốn test Swagger UI qua ngrok từ trình duyệt.

### 2.2. Build APK debug

```bash
cd UniShare.APP

# Cách 1: dùng dart-define (khuyên dùng — linh hoạt)
flutter build apk --debug --dart-define=NGROK_DOMAIN=<ngrok-domain>

# VD:
flutter build apk --debug --dart-define=NGROK_DOMAIN=abc123-def-456.ngrok-free.app
```

APK được tạo tại: `UniShare.APP\build\app\outputs\flutter-apk\app-debug.apk`

### 2.3. Cài lên thiết bị thật

```bash
# Cài trực tiếp nếu thiết bị đang kết nối qua USB
flutter install

# Hoặc copy APK sang thiết bị rồi cài thủ công
```

### 2.4. Cách khác: dùng ENV (static config)

```bash
# Dùng static config (cần sửa domain trong app_config.dart trước)
flutter build apk --debug --dart-define=ENV=ngrok
```

---

## 3. Cấu hình nhanh (cho lần sau)

ngrok free plan thay đổi URL mỗi lần restart. Quy trình cho lần sau:

```bash
# 1. Start Docker
docker compose up -d

# 2. Lấy URL mới
docker logs unishare-ngrok

# 3. Build APK với URL mới
cd UniShare.APP
flutter build apk --debug --dart-define=NGROK_DOMAIN=<url-moi>
```

---

## 4. Troubleshooting

| Vấn đề                               | Cách khắc phục                                                                                                                |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| `host.docker.internal` không resolve | Chỉ hoạt động trên Docker Desktop (Windows/Mac). Linux: thêm `extra_hosts: - "host.docker.internal:host-gateway"` vào compose |
| Không kết nối được SQL Server        | Kiểm tra SQL Server đang chạy: `Get-Service MSSQLSERVER` (PowerShell). Kiểm tra port 1433 đang mở                             |
| ngrok không có URL                   | Kiểm tra `NGROK_AUTHTOKEN` đã set: `echo $NGROK_AUTHTOKEN`                                                                    |
| APK không kết nối API                | Kiểm tra thiết bị có internet. Thử mở `https://<ngrok-domain>/swagger` trên browser thiết bị                                  |
| SignalR không hoạt động              | ngrok `proto: http` mặc định hỗ trợ WebSocket. Kiểm tra `signalrHubUrl` trong config khớp với ngrok domain                    |
| `error: 403` từ ngrok                | ngrok free plan có warning page. Thêm header `ngrok-skip-browser-warning: true` hoặc dùng ngrok agent trực tiếp               |

---

## 5. Thông tin tài khoản mặc định

| Trường               | Giá trị                            |
| -------------------- | ---------------------------------- |
| **Admin Email**      | `admin@unishare.edu.vn`            |
| **Admin Password**   | `Admin@123456!`                    |
| **API Base URL**     | `https://<ngrok-domain>/api/v1`    |
| **SignalR Chat Hub** | `https://<ngrok-domain>/hubs/chat` |
