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
