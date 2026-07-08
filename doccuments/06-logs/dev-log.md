# Nhật Ký Phát Triển

## 1. Mục Tiêu

Ghi lại các quyết định kỹ thuật quan trọng, vấn đề phát sinh và bài học kinh nghiệm trong quá trình phát triển.

## 2. Quy Ước

- hãy tạo file mới trong session-log với format tên `log-yyyymmdd-task.md` để lưu trữ log.
- Mỗi entry ghi: ngày, người thực hiện, loại (Decision / Issue / Lesson).
- Tham chiếu đến task liên quan từ `05-tasks/01-task-board.md`.
- Ghi ngắn gọn, tập trung vào WHY hơn là WHAT.

## 3. Entries

| Ngày       | Người thực hiện       | Loại     | Task                                                     | Mô tả                                                                                                                                                                                                                            |
| ---------- | --------------------- | -------- | -------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| 2026-06-21 | ThinhTT + Claude Code | Decision | DB-001 → DB-009                                          | Hoàn thành Phase 1: 16 entities, 6 enums, Fluent API configs, migration InitialCreate, seed data. [Chi tiết](session-log/log-20260621-phase1.md)                                                                                 |
| 2026-06-21 | ThinhTT + Claude Code | Decision | API-AUTH-001 → API-USER-003, API-META-003 → API-META-004 | Hoàn thành Phase 2: Auth & User API. 10 endpoints, BCrypt hashing, refresh token rotation, domain exceptions, FluentValidation. [Chi tiết](session-log/log-20260621-phase2-auth.md)                                              |
| 2026-06-21 | ThinhTT + Claude Code | Decision | API-META-001 → API-IMG-002                               | Hoàn thành Phase 2: Listing Discovery & Management. 13 endpoints, listing CRUD + search/filter/sort, tag auto-normalization, local image upload với static file serving. [Chi tiết](session-log/log-20260621-phase2-listings.md) |
| 2026-06-21 | ThinhTT + Claude Code | Decision | API-META-005                                            | Hoàn thành API-META-005: Admin APIs quản lý Categories/Schools/Areas. 9 endpoints (POST/PUT/PATCH-deactivate), authorization RequireAdmin, input DTOs + FluentValidation, AdminSeedService tự tạo admin user trong dev. [Chi tiết](session-log/log-20260621-phase2-admin.md) |
| 2026-06-21 | ThinhTT + Claude Code | Decision | API-INT-001 → API-INT-003                               | Hoàn thành Tương Tác Cộng Đồng: upvote/un-upvote, bình luận CRUD, soft-delete, notification. 6 endpoints, idempotent upvote, CommentDto phẳng, phân quyền xóa owner/admin. [Chi tiết](session-log/log-20260621-phase2-interactions.md) |
| 2026-06-22 | ThinhTT + Claude Code | Issue   | Build APK + Session Check                               | Fix Kotlin incremental cache corruption trên Windows (kotlin.incremental=false). Fix app treo "Đang kiểm tra phiên..." do 10.0.2.2 không hoạt động trên điện thoại thật + FlutterSecureStorage treo Samsung Knox. Thêm API_HOST dart-define. [Chi tiết](session-log/log-20260622-build-and-session-fix.md) |
| 2026-06-22 | ThinhTT + Claude Code | Issue   | TEST-FE-003, TEST-FE-004                                 | Fix `EditListingScreen._loadData()` gọi `loadExistingListing()` trực tiếp trong `build()` → vi phạm Riverpod rule (không sửa provider trong lifecycle). Wrap bằng `Future.microtask()`. Phát hiện khi viết widget test cho EditListingScreen. [Chi tiết](session-log/log-20260622-phase6-test-fe003-fe004.md) |
| 2026-06-22 | ThinhTT + Claude Code | Issue   | Real Device Test Bug Fixes (2 đợt)                     | Test app trên Samsung Galaxy A56 thật. Đợt 1: 5 lỗi (register FullName, login isVerified, listings depositAmount, filter overflow). Đợt 2: 2 lỗi (create listing validation, listing detail tags model). Fix 16 files, Dart analyzer 0 errors. [Chi tiết](session-log/log-20260622-real-device-test-bugfix.md) |
