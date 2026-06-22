# UniShare — Ứng dụng chia sẻ đồ dùng sinh viên

[![.NET](https://img.shields.io/badge/.NET-8.0-512BD4)](https://dotnet.microsoft.com/)
[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B)](https://flutter.dev/)
[![License](https://img.shields.io/badge/License-MIT-yellow)](LICENSE)

UniShare là ứng dụng mobile giúp sinh viên cho thuê, cho mượn và tìm kiếm đồ dùng học tập, thực hành hoặc sinh hoạt trong thời gian ngắn. Ứng dụng hướng đến việc tận dụng lại những món đồ sinh viên không còn sử dụng thường xuyên, đồng thời giúp sinh viên khác tiết kiệm chi phí mua mới.

> **Ý tưởng:** Trong môi trường đại học, nhiều sinh viên chỉ cần sử dụng một số đồ vật trong thời gian ngắn (máy tính cầm tay, giáo trình, bộ dụng cụ thực hành, máy ảnh, áo tốt nghiệp, dụng cụ thể thao…). Sau khi hoàn thành môn học hoặc sự kiện, các đồ dùng này thường bị bỏ không, trong khi những sinh viên khác vẫn có nhu cầu sử dụng và phải mua mới. UniShare giải quyết vấn đề này bằng nền tảng kết nối trực tiếp giữa người có đồ nhàn rỗi và người cần thuê/mượn.

---

## Mục tiêu

- Giúp sinh viên tiết kiệm chi phí mua sắm đồ dùng ngắn hạn.
- Tận dụng lại tài sản đang bị bỏ không trong cộng đồng sinh viên.
- Tạo môi trường chia sẻ minh bạch, có đánh giá uy tín và thông tin giao dịch rõ ràng.
- Hỗ trợ kết nối theo trường học hoặc khu vực để việc trao đổi thuận tiện hơn.

---

## Tính năng chính (MVP)

| #   | Tính năng                       | Mô tả                                                         |
| --- | ------------------------------- | ------------------------------------------------------------- |
| 1   | **Đăng ký, đăng nhập & hồ sơ**  | Đăng ký email/mật khẩu, JWT auth, cập nhật hồ sơ, điểm uy tín |
| 2   | **Đăng bài cho thuê/cho mượn**  | Tạo bài đăng kèm hình ảnh, loại đồ, tag, trường học, khu vực  |
| 3   | **Tìm kiếm & lọc**              | Tìm theo từ khóa, loại đồ, tag, trường học, khu vực           |
| 4   | **Chat realtime**               | Nhắn tin trực tiếp giữa người dùng qua SignalR                |
| 5   | **Đánh giá uy tín**             | Đánh giá lẫn nhau sau giao dịch, điểm uy tín tăng/giảm        |
| 6   | **Thông báo**                   | Thông báo khi có upvote, bình luận, tin nhắn, yêu cầu mới     |
| 7   | **Yêu cầu thuê/mượn & đặt cọc** | Gửi/chấp nhận/từ chối yêu cầu, ghi nhận trạng thái giao dịch  |

---

## Tech Stack

| Layer              | Công nghệ                     |
| ------------------ | ----------------------------- |
| **Mobile App**     | Flutter                       |
| **Backend**        | ASP.NET Core Web API (.NET 8) |
| **Database**       | Microsoft SQL Server          |
| **ORM**            | Entity Framework Core         |
| **Realtime**       | SignalR                       |
| **Authentication** | JWT Bearer token              |
| **API Docs**       | Swagger / OpenAPI             |

---

## Cấu trúc dự án

```
UniShare/
├── UniShare.API/          # Backend ASP.NET Core Web API
├── UniShare.APP/          # Flutter mobile app
├── docs/                  # Tài liệu dự án
│   ├── 01-project/        # Ý tưởng, phạm vi
│   ├── 02-architecture/   # Database, API spec
│   ├── 03-functional/     # Yêu cầu chức năng
│   ├── 04-ui/             # Sitemap, wireframe, color guidelines
│   ├── 05-tasks/          # Task board theo phase
│   └── 06-logs/           # Dev log & session log
├── tests/                 # Unit & integration tests
├── docker-compose.yml     # Docker Compose cho API + ngrok
├── global.json            # .NET SDK version
└── SETUP.md               # (đã chuyển nội dung vào README.md)
```

> 📖 Xem toàn bộ tài liệu tại [`docs/README.md`](docs/README.md)

---

## Hướng dẫn cài đặt

### Yêu cầu

- **Docker Desktop** đã cài và đang chạy
- **SQL Server** đang chạy trên máy host (localhost:1433)
- **Flutter SDK** + Android SDK (để build APK)
- **Tài khoản ngrok** (miễn phí) — lấy auth token tại https://dashboard.ngrok.com/get-started/your-authtoken

---

### 1. Chạy API với Docker + ngrok

#### 1.1. Set ngrok auth token

Dán ngrok auth token vào file `.env.example`, sau đó rename file thành `.env`:

```bash
mv .env.example .env
```

#### 1.2. Build và start containers

```bash
cd E:\UniShare
docker compose up -d --build
```

Lần đầu build sẽ mất vài phút để tải .NET SDK image. Các lần sau nhanh hơn nhờ Docker layer caching.

#### 1.3. Lấy ngrok URL

```bash
docker logs unishare-ngrok
```

Tìm dòng có dạng:

```
ngrok ...... url=https://xxxx-xxx-xxx.ngrok-free.app
```

Hoặc kiểm tra trên web dashboard: https://dashboard.ngrok.com/endpoints

Ví dụ URL: `https://abc123-def-456.ngrok-free.app`

#### 1.4. Kiểm tra API hoạt động

```bash
# Qua localhost
curl http://localhost:5056/swagger/v1/swagger.json

# Qua ngrok (public)
curl https://<ngrok-domain>/swagger/v1/swagger.json
```

Swagger UI có thể truy cập tại:

- **Local:** http://localhost:5056/swagger
- **Public:** https://\<ngrok-domain\>/swagger

#### 1.5. Quản lý containers

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

### 2. Build APK với ngrok URL

#### 2.1. Cập nhật CORS (nếu cần test Swagger qua ngrok)

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

#### 2.2. Build APK debug

```bash
cd UniShare.APP

# Cách 1: dùng dart-define (khuyên dùng — linh hoạt)
flutter build apk --debug --dart-define=NGROK_DOMAIN=<ngrok-domain>

# VD:
flutter build apk --debug --dart-define=NGROK_DOMAIN=abc123-def-456.ngrok-free.app
```

APK được tạo tại: `UniShare.APP\build\app\outputs\flutter-apk\app-debug.apk`

#### 2.3. Cài lên thiết bị thật

```bash
# Cài trực tiếp nếu thiết bị đang kết nối qua USB
flutter install

# Hoặc copy APK sang thiết bị rồi cài thủ công
```

#### 2.4. Cách khác: dùng ENV (static config)

```bash
# Dùng static config (cần sửa domain trong app_config.dart trước)
flutter build apk --debug --dart-define=ENV=ngrok
```

---

### 3. Cấu hình nhanh (cho lần sau)

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

## Tài khoản mặc định

| Trường               | Giá trị                            |
| -------------------- | ---------------------------------- |
| **Admin Email**      | `admin@unishare.edu.vn`            |
| **Admin Password**   | `Admin@123456!`                    |
| **API Base URL**     | `https://<ngrok-domain>/api/v1`    |
| **SignalR Chat Hub** | `https://<ngrok-domain>/hubs/chat` |

---

## Troubleshooting

| Vấn đề                               | Cách khắc phục                                                                                                                |
| ------------------------------------ | ----------------------------------------------------------------------------------------------------------------------------- |
| `host.docker.internal` không resolve | Chỉ hoạt động trên Docker Desktop (Windows/Mac). Linux: thêm `extra_hosts: - "host.docker.internal:host-gateway"` vào compose |
| Không kết nối được SQL Server        | Kiểm tra SQL Server đang chạy: `Get-Service MSSQLSERVER` (PowerShell). Kiểm tra port 1433 đang mở                             |
| ngrok không có URL                   | Kiểm tra `NGROK_AUTHTOKEN` đã set: `echo $NGROK_AUTHTOKEN`                                                                    |
| APK không kết nối API                | Kiểm tra thiết bị có internet. Thử mở `https://<ngrok-domain>/swagger` trên browser thiết bị                                  |
| SignalR không hoạt động              | ngrok `proto: http` mặc định hỗ trợ WebSocket. Kiểm tra `signalrHubUrl` trong config khớp với ngrok domain                    |
| `error: 403` từ ngrok                | ngrok free plan có warning page. Thêm header `ngrok-skip-browser-warning: true` hoặc dùng ngrok agent trực tiếp               |

---

## Tài liệu tham khảo

| Tài liệu                                                                                               | Mô tả                                                          |
| ------------------------------------------------------------------------------------------------------ | -------------------------------------------------------------- |
| [`docs/01-project/01-ideas-and-scope.md`](docs/01-project/01-ideas-and-scope.md)                       | Ý tưởng sản phẩm, phạm vi tổng thể, công nghệ và tính năng MVP |
| [`docs/02-architecture/01-database-designer.md`](docs/02-architecture/01-database-designer.md)         | ERD, chi tiết bảng, DB rules và luồng nghiệp vụ                |
| [`docs/02-architecture/02-api-spec.md`](docs/02-architecture/02-api-spec.md)                           | Quy ước API, DTO, endpoint, SignalR hub                        |
| [`docs/03-functional/01-functional-requirements.md`](docs/03-functional/01-functional-requirements.md) | Vai trò người dùng, use case chi tiết, business rules          |
| [`docs/04-ui/01-ui-sitemap-and-wireframe.md`](docs/04-ui/01-ui-sitemap-and-wireframe.md)               | Sitemap, wireframe, luồng UI                                   |
| [`docs/04-ui/02-color-guidelines.md`](docs/04-ui/02-color-guidelines.md)                               | Quy ước màu sắc, Flutter theme                                 |
| [`docs/05-tasks/01-task-board.md`](docs/05-tasks/01-task-board.md)                                     | Task board theo phase                                          |
