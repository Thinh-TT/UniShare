# Tài Liệu Dự Án - UniShare

**UniShare** là ứng dụng mobile chia sẻ đồ dùng sinh viên. Ứng dụng giúp sinh viên đăng cho thuê/cho mượn đồ dùng, tìm kiếm theo trường hoặc khu vực, chat realtime, gửi yêu cầu thuê/mượn, đánh giá uy tín, nhận thông báo và ghi nhận đặt cọc cơ bản.

## Xem Nhanh Thư Mục Docs

```text
docs/
├── README.md
├── AGENT.md
├── 01-project/
│   └── 01-ideas-and-scope.md
├── 02-architecture/
│   ├── 01-database-designer.md
│   └── 02-api-spec.md
├── 03-functional/
│   └── 01-functional-requirements.md
├── 04-ui/
│   ├── 01-ui-sitemap-and-wireframe.md
│   └── 02-color-guidelines.md
├── 05-tasks/
│   └── 01-task-board.md
└── 06-logs/
    ├── dev-log.md
    └── session-log/
```

## Danh Mục Tài Liệu

### 01 - Tổng Quan Và Phạm Vi

| # | Tài liệu | Mô tả |
| --- | --- | --- |
| 01 | `01-project/01-ideas-and-scope.md` | Tên đề tài, ý tưởng sản phẩm, phạm vi tổng thể, công nghệ sử dụng và tính năng MVP |

### 02 - Kiến Trúc Và Thiết Kế Kỹ Thuật

| # | Tài liệu | Mô tả |
| --- | --- | --- |
| 01 | `02-architecture/01-database-designer.md` | Mô tả database, ERD, chi tiết bảng, DB rules và luồng nghiệp vụ chính |
| 02 | `02-architecture/02-api-spec.md` | Quy ước API, DTO, endpoint, SignalR hub và mapping endpoint với use case |

### 03 - Yêu Cầu Chức Năng

| # | Tài liệu | Mô tả |
| --- | --- | --- |
| 01 | `03-functional/01-functional-requirements.md` | Vai trò người dùng, danh sách use case, use case chi tiết và business rules tổng hợp |

### 04 - UI Và Trải Nghiệm Người Dùng

| # | Tài liệu | Mô tả |
| --- | --- | --- |
| 01 | `04-ui/01-ui-sitemap-and-wireframe.md` | Sitemap, navigation mobile, danh sách màn hình, wireframe, luồng UI và traceability |
| 02 | `04-ui/02-color-guidelines.md` | Quy ước màu sắc, palette trắng/xanh lá, state color và gợi ý Flutter theme |

### 05 - Task Board

| # | Tài liệu | Mô tả |
| --- | --- | --- |
| 01 | `05-tasks/01-task-board.md` | Task theo phase từ backend ASP.NET Core API, test, Flutter UI, test mobile đến build APK |

### 06 - Logs

| # | Tài liệu | Mô tả |
| --- | --- | --- |
| 01 | `06-logs/dev-log.md` | Quy ước ghi log phát triển và quyết định kỹ thuật |
| 02 | `06-logs/session-log/` | Thư mục lưu log theo từng session/task |

### Hướng Dẫn Cho AI Agent

| # | Tài liệu | Mô tả |
| --- | --- | --- |
| 01 | `AGENT.md` | Quy tắc làm việc cho AI agent trong dự án UniShare |

## Liên Kết Nhanh Theo Module

| Module | Tài liệu nên đọc |
| --- | --- |
| Tổng quan sản phẩm | `01-project/01-ideas-and-scope.md` |
| Database/Entity/Migration | `02-architecture/01-database-designer.md` |
| Backend API | `02-architecture/02-api-spec.md`, `03-functional/01-functional-requirements.md` |
| Authentication/User/Profile | `03-functional/01-functional-requirements.md`, `02-architecture/02-api-spec.md` |
| Listings/Search/Images | `02-architecture/01-database-designer.md`, `02-architecture/02-api-spec.md`, `04-ui/01-ui-sitemap-and-wireframe.md` |
| Chat/SignalR | `02-architecture/02-api-spec.md`, `03-functional/01-functional-requirements.md` |
| Rental/Deposit/Review | `03-functional/01-functional-requirements.md`, `02-architecture/02-api-spec.md`, `04-ui/01-ui-sitemap-and-wireframe.md` |
| Flutter UI | `04-ui/01-ui-sitemap-and-wireframe.md`, `04-ui/02-color-guidelines.md` |
| Task planning | `05-tasks/01-task-board.md` |
| Dev log | `06-logs/dev-log.md`, `06-logs/session-log/` |

## Thứ Tự Đọc Đề Xuất

1. `01-project/01-ideas-and-scope.md`
2. `03-functional/01-functional-requirements.md`
3. `02-architecture/01-database-designer.md`
4. `02-architecture/02-api-spec.md`
5. `04-ui/01-ui-sitemap-and-wireframe.md`
6. `04-ui/02-color-guidelines.md`
7. `05-tasks/01-task-board.md`
8. `AGENT.md`

## Quy Ước Đặt Tên File

- Tiền tố số thứ tự: `01-`, `02-`, ... để giữ thứ tự trong từng nhóm.
- Tên file ngắn gọn, dùng tiếng Anh, phân cách bằng dấu gạch ngang.
- File markdown (`.md`), mã hóa UTF-8.

## Tech Stack Tóm Tắt

| Layer | Công nghệ |
| --- | --- |
| Mobile app | Flutter |
| Backend | ASP.NET Core Web API (.NET 8) |
| Database | Microsoft SQL Server |
| ORM | Entity Framework Core |
| Realtime | SignalR |
| Auth | JWT Bearer token |
