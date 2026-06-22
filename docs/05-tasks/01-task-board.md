# Task Board

## 1. Mục Tiêu

Bảng theo dõi công việc triển khai dự án UniShare từ lúc khởi tạo solution ASP.NET Core Web API, hoàn thiện API, viết test, xây dựng Flutter UI, test mobile đến build APK.

Task board này bám theo:

- `/docs/01-project/01-ideas-and-scope.md`
- `/docs/02-architecture/01-database-designer.md`
- `/docs/02-architecture/02-api-spec.md`
- `/docs/03-functional/01-functional-requirements.md`
- `/docs/04-ui/01-ui-sitemap-and-wireframe.md`
- `/docs/04-ui/02-color-guidelines.md`

## 2. Quy Ước Trạng Thái

| Ký hiệu | Trạng thái  | Ý nghĩa                       |
| ------- | ----------- | ----------------------------- |
| `[ ]`   | Todo        | Chưa bắt đầu                  |
| `[~]`   | In Progress | Đang thực hiện                |
| `[x]`   | Done        | Hoàn thành                    |
| `[!]`   | Blocked     | Bị chặn, cần xử lý dependency |

## 3. Quy Ước Ưu Tiên

| Ưu tiên | Ý nghĩa                                |
| ------- | -------------------------------------- |
| `P0`    | Bắt buộc cho MVP chạy được end-to-end  |
| `P1`    | Quan trọng cho trải nghiệm hoàn chỉnh  |
| `P2`    | Có thể làm sau MVP nếu thiếu thời gian |

## 4. Phase 0 - Chuẩn Bị Repository Và Môi Trường

| ID          | Task                                                        | Use Case           | Status | Priority | Dependency  | Definition of Done                                      |
| ----------- | ----------------------------------------------------------- | ------------------ | ------ | -------- | ----------- | ------------------------------------------------------- |
| `SETUP-001` | Tạo cấu trúc solution backend ASP.NET Core Web API .NET 8   | N/A                | `[x]`  | P0       | N/A         | Có solution backend, project API                        |
| `SETUP-002` | Tạo project test backend                                    | N/A                | `[x]`  | P0       | `SETUP-001` | Có project unit/integration test và chạy được lệnh test |
| `SETUP-003` | Cấu hình SQL Server connection string theo môi trường dev   | N/A                | `[x]`  | P0       | `SETUP-001` | App đọc được config, không hard-code secret production  |
| `SETUP-004` | Cấu hình Swagger/OpenAPI cho `/api/v1`                      | N/A                | `[x]`  | P0       | `SETUP-001` | Swagger hiển thị các nhóm API chính                     |
| `SETUP-005` | Cấu hình response lỗi ProblemDetails và validation pipeline | N/A                | `[x]`  | P0       | `SETUP-001` | API lỗi trả format thống nhất như API spec              |
| `SETUP-006` | Cấu hình JWT authentication và authorization policy cơ bản  | `FR-001`, `FR-002` | `[x]`  | P0       | `SETUP-001` | Endpoint protected yêu cầu token hợp lệ                 |
| `SETUP-007` | Cấu hình CORS cho Flutter app/dev environment               | N/A                | `[x]`  | P1       | `SETUP-001` | Mobile/debug client gọi được API                        |
| `SETUP-008` | Tạo Flutter project mobile UniShare                         | N/A                | `[x]`  | P0       | N/A         | App Flutter chạy được trên Android emulator/device      |
| `SETUP-009` | Cấu hình flavor/env cho Flutter gọi backend dev/staging     | N/A                | `[x]`  | P1       | `SETUP-008` | App đổi được base API URL theo môi trường               |

## 5. Phase 1 - Database, Entity Và Migration

| ID       | Task                                                                                     | Use Case                     | Status | Priority | Dependency          | Definition of Done                                       |
| -------- | ---------------------------------------------------------------------------------------- | ---------------------------- | ------ | -------- | ------------------- | -------------------------------------------------------- |
| `DB-001` | Tạo entity và DbSet cho `Users`, `Schools`, `Areas`                                      | `FR-001`, `FR-003`, `FR-004` | `[x]`  | P0       | `SETUP-001`         | Entity map đúng database designer                        |
| `DB-002` | Tạo entity và DbSet cho `Categories`, `Tags`, `Listings`, `ListingImages`, `ListingTags` | `FR-005` - `FR-010`          | `[x]`  | P0       | `DB-001`            | Quan hệ listing/category/tag/image hoạt động             |
| `DB-003` | Tạo entity cho `Upvotes`, `Comments`                                                     | `FR-011`, `FR-012`           | `[x]`  | P0       | `DB-002`            | Unique upvote và comment reply cùng listing được enforce |
| `DB-004` | Tạo entity cho `RentalRequests`, `Deposits`                                              | `FR-015` - `FR-019`          | `[x]`  | P0       | `DB-002`            | Trạng thái request/deposit map đúng enum                 |
| `DB-005` | Tạo entity cho `Conversations`, `Messages`                                               | `FR-013`, `FR-014`           | `[x]`  | P0       | `DB-002`            | Conversation participant và message relation đúng        |
| `DB-006` | Tạo entity cho `Reviews`, `Notifications`                                                | `FR-020`, `FR-021`           | `[x]`  | P0       | `DB-001`, `DB-004`  | Review/notification map đúng user/request                |
| `DB-007` | Cấu hình EF Core Fluent API, index, unique constraint, delete behavior                   | All                          | `[x]`  | P0       | `DB-001` - `DB-006` | Migration sinh constraint chính xác                      |
| `DB-008` | Tạo migration đầu tiên và cập nhật database dev                                          | All                          | `[x]`  | P0       | `DB-007`            | Database tạo được trên SQL Server                        |
| `DB-009` | Seed dữ liệu nền: schools, areas, categories, sample tags                                | `FR-008`, `FR-010`, `FR-022` | `[x]`  | P1       | `DB-008`            | App có dữ liệu chọn trường/khu vực/category              |

## 6. Phase 2 - Backend API Core

### 6.1. Auth Và User

| ID             | Task                                                             | Use Case           | Status | Priority | Dependency               | Definition of Done                                               |
| -------------- | ---------------------------------------------------------------- | ------------------ | ------ | -------- | ------------------------ | ---------------------------------------------------------------- |
| `API-AUTH-001` | Implement `POST /auth/register`                                  | `FR-001`           | `[x]`  | P0       | `DB-001`, `SETUP-006`    | Tạo user, hash password, điểm uy tín mặc định                    |
| `API-AUTH-002` | Implement `POST /auth/login`                                     | `FR-002`           | `[x]`  | P0       | `API-AUTH-001`           | Trả access token, refresh token và user summary                  |
| `API-AUTH-003` | Implement `POST /auth/refresh-token`                             | `FR-002`           | `[x]`  | P1       | `API-AUTH-002`           | Refresh token hợp lệ tạo access token mới                        |
| `API-AUTH-004` | Implement `POST /auth/logout`                                    | `FR-002`           | `[x]`  | P1       | `API-AUTH-002`           | Logout vô hiệu hóa refresh token hoặc hướng dẫn client xóa token |
| `API-USER-001` | Implement `GET /users/me`                                        | `FR-003`           | `[x]`  | P0       | `API-AUTH-002`           | User xem được hồ sơ của mình                                     |
| `API-USER-002` | Implement `PUT /users/me`                                        | `FR-003`           | `[x]`  | P0       | `API-USER-001`, `DB-009` | Cập nhật profile, validate school/area active                    |
| `API-USER-003` | Implement `GET /users/{userId}` và `GET /users/{userId}/reviews` | `FR-004`, `FR-020` | `[x]`  | P1       | `DB-006`                 | Trả hồ sơ công khai và danh sách review                          |

### 6.2. Metadata Và Admin Cơ Bản

| ID             | Task                                                  | Use Case           | Status | Priority | Dependency            | Definition of Done                       |
| -------------- | ----------------------------------------------------- | ------------------ | ------ | -------- | --------------------- | ---------------------------------------- |
| `API-META-001` | Implement `GET /categories`                           | `FR-008`, `FR-010` | `[x]`  | P0       | `DB-009`              | Trả category active                      |
| `API-META-002` | Implement `GET /tags` với keyword/paging              | `FR-008`, `FR-010` | `[x]`  | P0       | `DB-009`              | Tìm tag theo keyword                     |
| `API-META-003` | Implement `GET /schools`                              | `FR-003`, `FR-008` | `[x]`  | P0       | `DB-009`              | Trả school active                        |
| `API-META-004` | Implement `GET /areas`                                | `FR-003`, `FR-008` | `[x]`  | P0       | `DB-009`              | Trả area active, filter theo city nếu có |
| `API-META-005` | Implement admin APIs quản lý categories/schools/areas | `FR-022`           | `[x]`  | P2       | `SETUP-006`, `DB-009` | Admin tạo/sửa/deactivate dữ liệu nền     |

### 6.3. Listings Và Images

| ID             | Task                                                       | Use Case           | Status | Priority | Dependency               | Definition of Done                                         |
| -------------- | ---------------------------------------------------------- | ------------------ | ------ | -------- | ------------------------ | ---------------------------------------------------------- |
| `API-LIST-001` | Implement `GET /listings` với paging, search, filter, sort | `FR-009`, `FR-010` | `[x]`  | P0       | `DB-002`, `API-META-001` | Chỉ trả bài `Available`, chưa xóa                          |
| `API-LIST-002` | Implement `GET /listings/{listingId}`                      | `FR-009`           | `[x]`  | P0       | `API-LIST-001`           | Trả detail gồm owner, images, tags, category, school, area |
| `API-LIST-003` | Implement `POST /listings`                                 | `FR-005`, `FR-008` | `[x]`  | P0       | `API-AUTH-002`, `DB-002` | Tạo bài đúng validation, normalize tags                    |
| `API-LIST-004` | Implement `PUT /listings/{listingId}`                      | `FR-006`, `FR-008` | `[x]`  | P0       | `API-LIST-003`           | Chỉ owner được cập nhật                                    |
| `API-LIST-005` | Implement close/delete/my listings endpoints               | `FR-006`           | `[x]`  | P0       | `API-LIST-004`           | Đóng bài, xóa mềm, list bài của tôi                        |
| `API-IMG-001`  | Implement upload ảnh bài đăng                              | `FR-007`           | `[x]`  | P0       | `API-LIST-003`           | Upload multipart, giới hạn định dạng/kích thước            |
| `API-IMG-002`  | Implement đổi cover, sắp xếp và xóa ảnh                    | `FR-007`           | `[x]`  | P1       | `API-IMG-001`            | Mỗi listing chỉ có 1 cover, tối đa 10 ảnh                  |

### 6.4. Tương Tác Cộng Đồng

| ID            | Task                              | Use Case | Status | Priority | Dependency               | Definition of Done                                                 |
| ------------- | --------------------------------- | -------- | ------ | -------- | ------------------------ | ------------------------------------------------------------------ |
| `API-INT-001` | Implement upvote/hủy upvote       | `FR-011` | `[x]`  | P1       | `API-LIST-002`, `DB-003` | Unique upvote/user/listing, cập nhật count, thông báo cho chủ bài  |
| `API-INT-002` | Implement lấy danh sách comment   | `FR-012` | `[x]`  | P1       | `DB-003`                 | Trả comments theo listing, paging, newest first                    |
| `API-INT-003` | Implement tạo/sửa/xóa mềm comment | `FR-012` | `[x]`  | P1       | `API-INT-002`            | Validate ownership, reply cùng listing, admin xóa được mọi comment |

### 6.5. Chat Realtime

| ID             | Task                                       | Use Case | Status | Priority | Dependency               | Definition of Done                                    |
| -------------- | ------------------------------------------ | -------- | ------ | -------- | ------------------------ | ----------------------------------------------------- |
| `API-CHAT-001` | Implement tạo/mở conversation theo listing | `FR-013` | `[x]`  | P0       | `API-LIST-002`, `DB-005` | Một conversation cho mỗi listing-owner-requester      |
| `API-CHAT-002` | Implement list/detail conversation         | `FR-013` | `[x]`  | P0       | `API-CHAT-001`           | Chỉ participant xem được                              |
| `API-CHAT-003` | Implement message HTTP APIs                | `FR-014` | `[x]`  | P0       | `API-CHAT-002`           | Load/gửi/mark read messages                           |
| `API-CHAT-004` | Implement SignalR `/hubs/chat`             | `FR-014` | `[x]`  | P0       | `API-CHAT-003`           | Join group, SendMessage, MessageReceived, MessageRead |

### 6.6. Rental, Deposit, Review, Notification

| ID             | Task                                                          | Use Case           | Status | Priority | Dependency                                                  | Definition of Done                                     |
| -------------- | ------------------------------------------------------------- | ------------------ | ------ | -------- | ----------------------------------------------------------- | ------------------------------------------------------ |
| `API-REQ-001`  | Implement gửi rental request                                  | `FR-015`           | `[x]`  | P0       | `API-LIST-002`, `DB-004`                                    | Tạo request Pending, validate date/owner/status        |
| `API-REQ-002`  | Implement list/detail rental requests                         | `FR-017`           | `[x]`  | P0       | `API-REQ-001`                                               | User chỉ xem request liên quan                         |
| `API-REQ-003`  | Implement accept/reject/cancel request                        | `FR-016`           | `[x]`  | P0       | `API-REQ-002`                                               | Đổi trạng thái đúng role và rule                       |
| `API-REQ-004`  | Implement start/complete transaction                          | `FR-017`, `FR-019` | `[x]`  | P0       | `API-REQ-003`                                               | Chuyển trạng thái request/listing đúng                 |
| `API-DEP-001`  | Implement xem và ghi nhận deposit                             | `FR-018`           | `[x]`  | P1       | `API-REQ-001`                                               | Get deposit, mark paid, refund                         |
| `API-REV-001`  | Implement tạo review sau giao dịch                            | `FR-020`           | `[x]`  | P0       | `API-REQ-004`, `DB-006`                                     | Chỉ review khi Completed, cập nhật reputation          |
| `API-NOTI-001` | Implement tạo notification trong các action chính             | `FR-021`           | `[x]`  | P0       | `API-INT-001`, `API-CHAT-003`, `API-REQ-001`, `API-REV-001` | Upvote/comment/message/request/review tạo notification |
| `API-NOTI-002` | Implement notification list, unread count, mark read/read all | `FR-021`           | `[x]`  | P0       | `API-NOTI-001`                                              | User chỉ xem notification của mình                     |

## 7. Phase 3 - Backend Testing Và API Verification

| ID            | Task                                                      | Use Case            | Status | Priority | Dependency                    | Definition of Done                                    |
| ------------- | --------------------------------------------------------- | ------------------- | ------ | -------- | ----------------------------- | ----------------------------------------------------- |
| `TEST-BE-001` | Unit test auth service và password/token logic            | `FR-001`, `FR-002`  | `[x]`  | P0       | `API-AUTH-004`                | Test pass cho register/login/refresh/logout           |
| `TEST-BE-002` | Unit test listing validation và ownership rules           | `FR-005` - `FR-008` | `[x]`  | P0       | `API-LIST-005`                | Cover rule, borrow price, owner-only update được test |
| `TEST-BE-003` | Unit test rental request state machine                    | `FR-015` - `FR-019` | `[x]`  | P0       | `API-REQ-004`                 | Pending/Accepted/InProgress/Completed transition đúng |
| `TEST-BE-004` | Unit test reputation/review rules                         | `FR-020`            | `[x]`  | P0       | `API-REV-001`                 | Không review trùng, reputation cập nhật đúng          |
| `TEST-BE-005` | Integration test Auth/Users endpoints                     | `FR-001` - `FR-004` | `[x]`  | P0       | `TEST-BE-001`                 | API trả status code và response đúng spec             |
| `TEST-BE-006` | Integration test Listings/Search/Images endpoints         | `FR-005` - `FR-010` | `[x]`  | P0       | `TEST-BE-002`                 | CRUD listing, search filter, upload ảnh chạy được     |
| `TEST-BE-007` | Integration test Upvote/Comment endpoints                 | `FR-011`, `FR-012`  | `[x]`  | P1       | `API-INT-003`                 | Count và notification đúng                            |
| `TEST-BE-008` | Integration test Chat/SignalR flow                        | `FR-013`, `FR-014`  | `[x]`  | P1       | `API-CHAT-004`                | Gửi/nhận message realtime trong test (REST endpoints) |
| `TEST-BE-009` | Integration test Rental/Deposit/Review/Notification flow  | `FR-015` - `FR-021` | `[x]`  | P0       | `API-NOTI-002`                | End-to-end giao dịch hoàn tất và review được          |
| `TEST-BE-010` | Kiểm thử Swagger/OpenAPI thủ công bằng Postman/Swagger UI | All API             | `[x]`  | P0       | `TEST-BE-005` - `TEST-BE-009` | Checklist Swagger đã viết tại session log             |
| `TEST-BE-011` | Kiểm tra security: unauthorized/forbidden cases           | All protected API   | `[x]`  | P0       | `TEST-BE-005` - `TEST-BE-009` | API private trả 401/403 đúng                          |

## 8. Phase 4 - Flutter Foundation

| ID            | Task                                                                      | Use Case      | Status | Priority | Dependency                   | Definition of Done                                       |
| ------------- | ------------------------------------------------------------------------- | ------------- | ------ | -------- | ---------------------------- | -------------------------------------------------------- |
| `FE-CORE-001` | Cấu hình theme màu trắng/xanh lá theo color guidelines                    | N/A           | `[x]`  | P0       | `SETUP-008`                  | Theme dùng đúng token màu trong `02-color-guidelines.md` |
| `FE-CORE-002` | Thiết lập routing/navigation theo sitemap                                 | All UI        | `[x]`  | P0       | `SETUP-008`                  | Có bottom tabs và stacks chính                           |
| `FE-CORE-003` | Tạo API client, interceptors, token storage                               | All API       | `[x]`  | P0       | `SETUP-009`                  | Gọi API, attach token, handle 401                        |
| `FE-CORE-004` | Tạo model/DTO mapping cho API response                                    | All API       | `[x]`  | P0       | `FE-CORE-003`                | Parse được response wrapper/list/paging                  |
| `FE-CORE-005` | Tạo component dùng chung: button, input, card, badge, empty/error/loading | All UI        | `[x]`  | P0       | `FE-CORE-001`                | UI component nhất quán                                   |
| `FE-CORE-006` | Tạo auth guard và login required modal                                    | Auth/UI rules | `[x]`  | P0       | `FE-CORE-002`, `FE-CORE-003` | Khách bị redirect khi dùng action private                |

## 9. Phase 5 - Flutter UI Screens

### 9.1. Auth Và Profile

| ID            | Task                       | Use Case           | Status | Priority | Dependency                    | Definition of Done                 |
| ------------- | -------------------------- | ------------------ | ------ | -------- | ----------------------------- | ---------------------------------- |
| `FE-AUTH-001` | Build Splash/Onboarding    | `FR-002`           | `[x]`  | P0       | `FE-CORE-002`                 | Kiểm tra token và điều hướng đúng  |
| `FE-AUTH-002` | Build Login screen         | `FR-002`           | `[x]`  | P0       | `FE-CORE-003`                 | Login thành công lưu token         |
| `FE-AUTH-003` | Build Register screen      | `FR-001`           | `[x]`  | P0       | `FE-AUTH-002`                 | Đăng ký và quay về login/main flow |
| `FE-PROF-001` | Build Profile/Edit Profile | `FR-003`, `FR-004` | `[x]`  | P0       | `FE-AUTH-002`, `API-USER-002` | Xem/sửa hồ sơ, chọn school/area    |

### 9.2. Listing Discovery Và Management

| ID            | Task                               | Use Case                               | Status | Priority | Dependency                    | Definition of Done                             |
| ------------- | ---------------------------------- | -------------------------------------- | ------ | -------- | ----------------------------- | ---------------------------------------------- |
| `FE-LIST-001` | Build Home/Listings screen         | `FR-009`, `FR-010`                     | `[x]`  | P0       | `FE-CORE-005`, `API-LIST-001` | List bài, pull-to-refresh, loading/empty/error |
| `FE-LIST-002` | Build Search + Filter bottom sheet | `FR-010`                               | `[x]`  | P0       | `FE-LIST-001`, `API-META-004` | Filter category/tag/school/area/type/price     |
| `FE-LIST-003` | Build Listing Detail screen        | `FR-004`, `FR-009`, `FR-011`, `FR-015` | `[x]`  | P0       | `FE-LIST-001`, `API-LIST-002` | Detail, owner summary, CTA theo role/status    |
| `FE-LIST-004` | Build Create Listing form          | `FR-005`, `FR-008`                     | `[x]`  | P0       | `FE-CORE-006`, `API-LIST-003` | Tạo bài, validate borrow price/tag/category    |
| `FE-LIST-005` | Build Edit Listing và My Listings  | `FR-006`, `FR-008`                     | `[x]`  | P0       | `FE-LIST-004`, `API-LIST-005` | Owner sửa/đóng/xóa mềm bài                     |
| `FE-LIST-006` | Build Manage Images screen         | `FR-007`                               | `[x]`  | P0       | `FE-LIST-004`, `API-IMG-002`  | Upload, cover, reorder, delete ảnh             |

### 9.3. Interaction, Chat, Rental

| ID            | Task                                     | Use Case                     | Status | Priority | Dependency                    | Definition of Done                            |
| ------------- | ---------------------------------------- | ---------------------------- | ------ | -------- | ----------------------------- | --------------------------------------------- |
| `FE-INT-001`  | Build Upvote action trong Listing Detail | `FR-011`                     | `[x]`  | P1       | `FE-LIST-003`, `API-INT-001`  | Toggle upvote, update count                   |
| `FE-INT-002`  | Build Comments screen                    | `FR-012`                     | `[x]`  | P1       | `FE-LIST-003`, `API-INT-003`  | List/create/reply/edit/delete comment         |
| `FE-CHAT-001` | Build Conversation List                  | `FR-013`                     | `[x]`  | P0       | `FE-CORE-006`, `API-CHAT-002` | List hội thoại và unread indicator            |
| `FE-CHAT-002` | Build Chat Detail + SignalR client       | `FR-014`                     | `[x]`  | P0       | `FE-CHAT-001`, `API-CHAT-004` | Realtime send/receive/mark read               |
| `FE-REQ-001`  | Build Rental Request Form                | `FR-015`                     | `[ ]`  | P0       | `FE-LIST-003`, `API-REQ-001`  | Chọn ngày, tính tiền, gửi request             |
| `FE-REQ-002`  | Build My Rental Requests                 | `FR-017`                     | `[ ]`  | P0       | `API-REQ-002`                 | Segment tôi gửi/gửi đến tôi                   |
| `FE-REQ-003`  | Build Rental Request Detail              | `FR-016`, `FR-017`, `FR-019` | `[ ]`  | P0       | `FE-REQ-002`, `API-REQ-004`   | Accept/reject/cancel/start/complete theo role |
| `FE-DEP-001`  | Build Deposit Status screen              | `FR-018`                     | `[ ]`  | P1       | `FE-REQ-003`, `API-DEP-001`   | Xem/mark paid/refund theo MVP                 |
| `FE-REV-001`  | Build Review Form                        | `FR-020`                     | `[ ]`  | P0       | `FE-REQ-003`, `API-REV-001`   | Review sau Completed, không review trùng      |
| `FE-NOTI-001` | Build Notifications screen và badge      | `FR-021`                     | `[ ]`  | P0       | `API-NOTI-002`                | List/read/read all/deep link                  |

## 10. Phase 6 - Flutter Testing

| ID            | Task                                                           | Use Case            | Status | Priority | Dependency                                         | Definition of Done                                            |
| ------------- | -------------------------------------------------------------- | ------------------- | ------ | -------- | -------------------------------------------------- | ------------------------------------------------------------- |
| `TEST-FE-001` | Unit test API client và DTO parsing                            | All API             | `[ ]`  | P0       | `FE-CORE-004`                                      | Parse success/error/paging đúng                               |
| `TEST-FE-002` | Unit/widget test Login/Register/Profile                        | `FR-001` - `FR-003` | `[ ]`  | P0       | `FE-AUTH-003`, `FE-PROF-001`                       | Validate form và state loading/error                          |
| `TEST-FE-003` | Widget test Home/Search/Listing Detail                         | `FR-009` - `FR-011` | `[ ]`  | P0       | `FE-LIST-003`                                      | List/filter/detail/guest CTA đúng                             |
| `TEST-FE-004` | Widget test Create/Edit Listing/Images                         | `FR-005` - `FR-008` | `[ ]`  | P0       | `FE-LIST-006`                                      | Form validation và image states đúng                          |
| `TEST-FE-005` | Widget test Comments/Chat                                      | `FR-012` - `FR-014` | `[ ]`  | P1       | `FE-CHAT-002`, `FE-INT-002`                        | Comment actions và chat states đúng                           |
| `TEST-FE-006` | Widget test Rental/Deposit/Review                              | `FR-015` - `FR-020` | `[ ]`  | P0       | `FE-REV-001`                                       | Role-based actions và state transition UI đúng                |
| `TEST-FE-007` | Widget test Notifications                                      | `FR-021`            | `[ ]`  | P1       | `FE-NOTI-001`                                      | Badge, read/read all, deep link đúng                          |
| `TEST-FE-008` | Integration test mobile happy path end-to-end                  | MVP flow            | `[ ]`  | P0       | `TEST-FE-001` - `TEST-FE-007`, backend dev chạy ổn | Register/login/listing/request/chat/complete/review chạy được |
| `TEST-FE-009` | Test thủ công trên Android emulator và ít nhất 1 thiết bị thật | MVP flow            | `[ ]`  | P0       | `TEST-FE-008`                                      | Không lỗi layout, không crash trong flow chính                |

## 11. Phase 7 - Build APK Và Release Candidate

| ID          | Task                                                          | Use Case | Status | Priority | Dependency                 | Definition of Done                          |
| ----------- | ------------------------------------------------------------- | -------- | ------ | -------- | -------------------------- | ------------------------------------------- |
| `BUILD-001` | Cấu hình Android app id, app name, icon, splash               | N/A      | `[ ]`  | P0       | `SETUP-008`, `FE-CORE-001` | App cài đặt hiển thị đúng tên UniShare      |
| `BUILD-002` | Cấu hình permission Android: internet, camera/gallery nếu cần | N/A      | `[ ]`  | P0       | `FE-LIST-006`              | Upload ảnh hoạt động trên thiết bị          |
| `BUILD-003` | Cấu hình signing key cho debug/release                        | N/A      | `[ ]`  | P0       | `BUILD-001`                | Có hướng dẫn build release APK              |
| `BUILD-004` | Build debug APK                                               | N/A      | `[ ]`  | P0       | `TEST-FE-009`              | `flutter build apk --debug` thành công      |
| `BUILD-005` | Build release APK                                             | N/A      | `[ ]`  | P0       | `BUILD-003`, `TEST-FE-009` | `flutter build apk --release` thành công    |
| `BUILD-006` | Smoke test APK release trên thiết bị thật                     | MVP flow | `[ ]`  | P0       | `BUILD-005`                | Cài được APK, login và flow chính hoạt động |
| `BUILD-007` | Chuẩn bị release notes và danh sách known issues              | N/A      | `[ ]`  | P1       | `BUILD-006`                | Có ghi chú phiên bản MVP và lỗi còn lại     |

## 12. Milestones Đề Xuất

| Milestone                      | Điều kiện hoàn thành                                          | Task chính                                                                     |
| ------------------------------ | ------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| `M1 - Backend Skeleton Ready`  | Backend chạy được, Swagger mở được, DB migrate được           | `SETUP-*`, `DB-*`                                                              |
| `M2 - Core API Ready`          | Auth, user, metadata, listing API hoàn thành                  | `API-AUTH-*`, `API-USER-*`, `API-META-*`, `API-LIST-*`, `API-IMG-*`            |
| `M3 - MVP API Complete`        | Chat, rental, deposit, review, notification API hoàn thành ✅ | `API-INT-*`, `API-CHAT-*`, `API-REQ-*`, `API-DEP-*`, `API-REV-*`, `API-NOTI-*` |
| `M4 - Backend Verified`        | Unit/integration tests chính pass ✅                          | `TEST-BE-*`                                                                    |
| `M5 - Flutter MVP UI Complete` | Tất cả màn hình UI-001 đến UI-020 hoàn thành                  | `FE-CORE-*`, `FE-*`                                                            |
| `M6 - Mobile Verified`         | Widget/integration/manual tests pass                          | `TEST-FE-*`                                                                    |
| `M7 - APK Release Candidate`   | Build release APK và smoke test thành công                    | `BUILD-*`                                                                      |

## 13. Ghi Chú Blockers

| Ngày       | Task        | Vấn đề                                                                                                                                   | Hướng giải quyết                                                                                                              |
| ---------- | ----------- | ---------------------------------------------------------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------- |
| 2026-06-22 | `FE-CORE-*` | Code đã viết xong (~92 files). Cần chạy `flutter pub get` + `dart run build_runner build` + `flutter analyze` + `flutter test` để verify | ✅ Done 2026-06-22: pub get (Dart 3.12.0 từ C:\dev\flutter), build_runner (66 outputs), analyze (0 errors), test (11/11 pass) |

## 14. Ghi Chú Kỹ Thuật

- Backend nên tách DTO request/response khỏi EF Core entity.
- Các API protected phải kiểm tra authentication ở endpoint/controller và ownership trong service.
- Các lỗi validation/business rule nên trả ProblemDetails-compatible response.
- Integration test backend nên ưu tiên database test gần thực tế như SQLite in-memory hoặc SQL Server test container/local DB.
- Flutter cần có state Loading/Empty/Error/Unauthorized/Forbidden cho các màn hình chính.
- APK MVP chỉ cần ghi nhận đặt cọc cơ bản, chưa cần tích hợp cổng thanh toán thật.
