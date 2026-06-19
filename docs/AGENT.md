# Agent Instructions

Hướng dẫn cho AI agent khi làm việc trên dự án **UniShare - Ứng dụng chia sẻ đồ dùng sinh viên**.

UniShare là mobile app giúp sinh viên đăng cho thuê/cho mượn đồ dùng, tìm kiếm theo trường/khu vực, chat realtime, gửi yêu cầu thuê/mượn, đánh giá uy tín, nhận thông báo và ghi nhận đặt cọc cơ bản.

## 1. Tech Stack

| Layer          | Công nghệ                     |
| -------------- | ----------------------------- |
| Mobile app     | Flutter                       |
| Backend        | ASP.NET Core Web API (.NET 8) |
| Database       | Microsoft SQL Server          |
| Data access    | Entity Framework Core         |
| Realtime       | SignalR                       |
| Authentication | JWT Bearer token              |
| API docs       | Swagger/OpenAPI               |

## 2. Nguyên Tắc Chung

- Bám theo tài liệu trong `docs/` trước khi implement.
- Không tự ý mở rộng scope ngoài MVP nếu chưa có yêu cầu rõ ràng.
- Ưu tiên code rõ ràng, dễ test, dễ map với use case `FR-*`.
- Tách DTO request/response khỏi entity database.
- Backend phải trả lỗi theo format ProblemDetails-compatible như API spec.
- Flutter UI phải bám sitemap, wireframe và color guidelines.
- Với tính năng realtime, SignalR chỉ là kênh giao tiếp; business logic vẫn nằm trong service/backend.

## 3. Thứ Tự Đọc Tài Liệu Khi Làm Việc

Trước khi triển khai một task, đọc theo thứ tự:

1. `05-tasks/01-task-board.md` để biết task, dependency và definition of done.
2. `03-functional/01-functional-requirements.md` để hiểu use case và business rule.
3. `02-architecture/02-api-spec.md` nếu task liên quan API contract.
4. `02-architecture/01-database-designer.md` nếu task liên quan entity, migration hoặc query.
5. `04-ui/01-ui-sitemap-and-wireframe.md` nếu task liên quan Flutter UI/navigation.
6. `04-ui/02-color-guidelines.md` nếu task liên quan theme, component hoặc visual style.
7. `06-logs/dev-log.md` và `06-logs/session-log/` để xem quyết định kỹ thuật trước đó.

## 4. Quy Trình Làm Việc

1. **Xác định task**: lấy ID task từ `05-tasks/01-task-board.md`.
2. **Đọc tài liệu liên quan**: kiểm tra use case, API, DB, UI tương ứng.
3. **Kiểm tra code hiện có**: tìm pattern tương tự trước khi thêm code mới.
4. **Implement theo từng module nhỏ**: giữ thay đổi gần với task, tránh refactor ngoài phạm vi.
5. **Viết hoặc cập nhật test**: unit/integration/widget test tùy loại task.
6. **Chạy kiểm tra phù hợp**: build/test backend hoặc Flutter trước khi kết luận hoàn thành.
7. **Cập nhật log nếu cần**: ghi quyết định kỹ thuật quan trọng vào `06-logs/session-log/`.
8. **Cập nhật task status**: chỉ đổi `[x]` khi definition of done đã đạt.

## 5. Backend Guidelines

- Dùng ASP.NET Core Web API .NET 8.
- Có thể dùng controller-based API hoặc Minimal API, nhưng phải thống nhất trong project.
- Dùng EF Core migration có chủ đích, không chỉnh database thủ công nếu không ghi log.
- Validation phải nằm ở DTO/service boundary, không chỉ dựa vào database constraint.
- Các endpoint protected phải kiểm tra JWT và ownership:
  - chủ bài đăng mới được sửa/xóa bài;
  - participant mới được xem chat;
  - owner/requester mới được xem rental request;
  - user chỉ xem notification của chính mình.
- API danh sách phải hỗ trợ paging theo API spec.
- Không lưu mật khẩu plain text.
- Không hard-code secret hoặc connection string production.

## 6. Flutter UI Guidelines

- UI là mobile app cho sinh viên, không phải admin dashboard.
- Màu chủ đạo là trắng, màu nhấn là xanh lá theo `04-ui/02-color-guidelines.md`.
- Mỗi màn hình chính cần có state: Loading, Empty, Error, Unauthorized/Forbidden nếu phù hợp.
- Guest user được xem/tìm kiếm bài đăng nhưng khi upvote, comment, chat hoặc gửi yêu cầu phải điều hướng login.
- Chủ bài đăng không thấy CTA thuê/mượn trên bài của mình.
- Bài đăng không `Available` thì disable/ẩn CTA gửi yêu cầu.
- Review chỉ hiển thị sau khi giao dịch `Completed`.

## 7. Testing Guidelines

Backend:

- Unit test cho service/business rule.
- Integration test cho API, auth, database và ownership.
- Test các status code chính: `200`, `201`, `204`, `400`, `401`, `403`, `404`, `409`, `422`.

Flutter:

- Unit test API client và DTO parsing.
- Widget test form validation, loading/empty/error state.
- Integration/manual test happy path: register/login, tạo bài, tìm kiếm, chat, gửi yêu cầu, hoàn tất, đánh giá.

## 8. Dev Log

Khi có quyết định kỹ thuật quan trọng hoặc blocker, tạo file trong:

```text
docs/06-logs/session-log/log-yyyymmdd-task.md
```

Nội dung nên có:

- Ngày.
- Người thực hiện.
- Task liên quan.
- Loại: Decision / Issue / Lesson.
- Nội dung ngắn gọn, tập trung vào lý do và tác động.

## 9. Commit Convention

```text
<type>: <short description>
```

Type:

- `feat`: tính năng mới.
- `fix`: sửa lỗi.
- `refactor`: tái cấu trúc code.
- `docs`: cập nhật tài liệu.
- `style`: format, không thay đổi logic.
- `test`: thêm/sửa test.
- `chore`: build, config, dependencies.

Ví dụ:

```text
feat: implement listing search api
docs: update ui color guidelines
test: add rental request state tests
```

## 10. Tài Liệu Tham Khảo Nhanh

| Tài liệu                | Đường dẫn                                     | Dùng khi                           |
| ----------------------- | --------------------------------------------- | ---------------------------------- |
| Ideas and Scope         | `01-project/01-ideas-and-scope.md`            | Cần hiểu mục tiêu sản phẩm và MVP  |
| Database Designer       | `02-architecture/01-database-designer.md`     | Thiết kế entity, migration, query  |
| API Spec                | `02-architecture/02-api-spec.md`              | Thiết kế endpoint, DTO, response   |
| Functional Requirements | `03-functional/01-functional-requirements.md` | Xác định use case và business rule |
| UI Sitemap/Wireframe    | `04-ui/01-ui-sitemap-and-wireframe.md`        | Thiết kế màn hình Flutter          |
| Color Guidelines        | `04-ui/02-color-guidelines.md`                | Theme và visual style              |
| Task Board              | `05-tasks/01-task-board.md`                   | Theo dõi công việc                 |
| Dev Log                 | `06-logs/dev-log.md`                          | Quy ước ghi log                    |
