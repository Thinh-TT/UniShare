# Session Log — Phase 2.6: Rental, Deposit, Review, Notification

- **Date:** 2026-06-22
- **Người thực hiện:** ThinhTT + Claude (deepseek-v4-pro)
- **Tasks:** `API-REQ-001` → `API-REQ-004`, `API-DEP-001`, `API-REV-001`, `API-NOTI-001` → `API-NOTI-002`
- **Loại:** Implementation
- **Plan:** `C:\Users\trant\.claude_deepseek\plans\h-y-c-t-i-li-u-rippling-hinton.md`

## Tóm Tắt

Hoàn thành toàn bộ 8 task Phase 2.6 — rental, deposit, review, notification — khép lại Phase 2 Backend API Core:

| Task | Mô tả | Kết quả |
|------|-------|---------|
| `API-NOTI-001` | Notification trong các action chính | `INotificationService` reusable + tích hợp trong Rental/Deposit/Review services |
| `API-NOTI-002` | Notification list, unread count, mark read | GET + PATCH endpoints tại `/me/notifications` |
| `API-REQ-001` | Gửi rental request | POST `/listings/{id}/rental-requests` — 201 |
| `API-REQ-002` | List/detail rental requests | GET `/me/rental-requests` + GET `/rental-requests/{id}` |
| `API-REQ-003` | Accept/reject/cancel request | 3 PATCH endpoints |
| `API-REQ-004` | Start/complete transaction | 2 PATCH endpoints |
| `API-DEP-001` | Xem và ghi nhận deposit | GET + 2 PATCH endpoints |
| `API-REV-001` | Tạo review sau giao dịch | POST `/rental-requests/{id}/reviews` — 201 |

## Files Created (23)

| File | Purpose |
|------|---------|
| `Services/Interfaces/INotificationService.cs` | Interface: Create, Get, UnreadCount, MarkAsRead, MarkAllAsRead |
| `Services/NotificationService.cs` | Implementation + SignalR broadcast real-time |
| `Services/Interfaces/IRentalService.cs` | Interface 8 methods: Create, List, Detail, Accept, Reject, Cancel, Start, Complete |
| `Services/RentalService.cs` | Core business logic: state machine, auto-reject, deposit creation, notifications |
| `Services/Interfaces/IDepositService.cs` | Interface 3 methods: GetDeposit, MarkAsPaid, Refund |
| `Services/DepositService.cs` | Deposit logic với ownership checks |
| `Services/Interfaces/IReviewService.cs` | Interface: CreateReview |
| `Services/ReviewService.cs` | Review creation + reputation update `(Rating-3)*10` |
| `Controllers/NotificationsController.cs` | 4 endpoints: list, unread-count, mark-read, read-all |
| `Controllers/RentalRequestsController.cs` | 8 endpoints: create → complete |
| `Controllers/DepositsController.cs` | 3 endpoints: get, mark-paid, refund |
| `Controllers/ReviewsController.cs` | 1 endpoint: create review |
| `Hubs/NotificationHub.cs` | SignalR hub: user joins own group on connect |
| `Models/DTOs/Notifications/NotificationDto.cs` | Response DTO |
| `Models/DTOs/Notifications/NotificationFilterParams.cs` | Query filter (IsRead?, Type?, page, pageSize) |
| `Models/DTOs/RentalRequests/CreateRentalRequest.cs` | Request: StartDate, EndDate, Message? |
| `Models/DTOs/RentalRequests/RentalRequestSummaryDto.cs` | List item với counterpart info + role |
| `Models/DTOs/RentalRequests/RentalRequestDetailDto.cs` | Full detail + listing + requester + owner + nested deposit |
| `Models/DTOs/Deposits/DepositDto.cs` | Response DTO |
| `Models/DTOs/Reviews/CreateReviewRequest.cs` | Request: Rating (1-5), Comment? |
| `Models/DTOs/Reviews/ReviewDto.cs` | Response DTO |
| `Validators/RentalRequests/CreateRentalRequestValidator.cs` | StartDate >= today, EndDate > StartDate, message max 500 |
| `Validators/Reviews/CreateReviewRequestValidator.cs` | Rating 1-5, comment max 1000 |

## Files Modified (4)

| File | Change |
|------|--------|
| `Extensions/ServiceCollectionExtensions.cs` | Thêm 4 AddScoped: INotificationService, IRentalService, IDepositService, IReviewService |
| `Program.cs` | Thêm `app.MapHub<NotificationHub>("/hubs/notifications")` |
| `Data/Configurations/ReviewConfiguration.cs` | Thêm unique index `(RentalRequestId, ReviewerId)` |
| `Data/Configurations/RentalRequestConfiguration.cs` | Thêm composite index `(ListingId, RequesterId, Status)` |

## Migration

- **Name:** `20260621165243_AddPhase2Indexes`
- **Nội dung:**
  - `CREATE UNIQUE INDEX [IX_Reviews_RentalRequestId_ReviewerId] ON [Reviews] ([RentalRequestId], [ReviewerId])`
  - `CREATE INDEX [IX_RentalRequests_ListingId_RequesterId_Status] ON [RentalRequests] ([ListingId], [RequesterId], [Status])`
- **Status:** Created, chưa applied

## Quyết Định Kỹ Thuật

### 1. Tách riêng INotificationService
Thay vì tiếp tục tạo notification inline như InteractionService/ChatService, tạo `INotificationService` làm foundation service. Các service mới (Rental, Deposit, Review) đều inject và dùng service này. Lý do:
- Tránh trùng lặp code tạo notification (Id, UserId, Type, Title, Body, ReferenceId, ...)
- Tích hợp SignalR real-time push tập trung một chỗ
- Cung cấp luôn các endpoint list/unread-count/mark-read

### 2. Giữ nguyên notification inline trong InteractionService/ChatService
Không refactor code cũ để tránh scope creep. Hai service đó tạo notification trực tiếp — vẫn hoạt động đúng. Có thể refactor sau nếu cần.

### 3. State machine bằng static dictionary
```csharp
Pending → [Accepted, Rejected, Cancelled]
Accepted → [Cancelled, InProgress]
InProgress → [Completed]
```
Mỗi PATCH endpoint gọi `EnsureValidTransition()` — throw 409 nếu transition không hợp lệ.

### 4. Auto-reject trên Accept
Khi owner accept một request Pending, tất cả request Pending khác cho cùng listing bị tự động Rejected. Mỗi requester bị từ chối nhận một notification riêng.

### 5. Deposit tạo khi StartTransaction (không phải Accept)
Deposit chỉ được tạo khi giao dịch thực sự bắt đầu (InProgress), với status `Pending`. Điều này gắn deposit lifecycle với thời gian thuê thực tế.

### 6. Reputation delta = (Rating - 3) × 10
- 5★ → +20, 4★ → +10, 3★ → 0, 2★ → -10, 1★ → -20
- ReputationScore không xuống dưới 0 (`Math.Max(0, ...)`)

### 7. Listing status luôn đồng bộ với rental status
| Rental Status | Listing Status |
|---------------|----------------|
| Pending | Available (không đổi) |
| Accepted | Reserved |
| InProgress | InUse |
| Completed | Available |
| Cancelled (từ Accepted) | Available (revert) |

### 8. Either party có thể Complete
Không chỉ owner — cả requester lẫn owner đều có thể đánh dấu giao dịch hoàn tất. Thực tế cả hai bên đều có nhu cầu này.

### 9. NotificationHub group = userId
User join group theo `userId.ToString()` khi connect. `NotificationService` push event `NotificationReceived` vào group này. Pattern giống hệt ChatHub.

## API Contract

### RentalRequests (`api/v1`)
| Method | Endpoint | Auth | Response |
|--------|----------|------|----------|
| POST | `/listings/{listingId}/rental-requests` | Required | 201 `RentalRequestDetailDto` |
| GET | `/me/rental-requests` | Required | 200 `PagedResponse<RentalRequestSummaryDto>` |
| GET | `/rental-requests/{requestId}` | Required | 200 `RentalRequestDetailDto` |
| PATCH | `/rental-requests/{requestId}/accept` | Required | 200 `RentalRequestDetailDto` |
| PATCH | `/rental-requests/{requestId}/reject` | Required | 200 `RentalRequestDetailDto` |
| PATCH | `/rental-requests/{requestId}/cancel` | Required | 200 `RentalRequestDetailDto` |
| PATCH | `/rental-requests/{requestId}/start` | Required | 200 `RentalRequestDetailDto` |
| PATCH | `/rental-requests/{requestId}/complete` | Required | 200 `RentalRequestDetailDto` |

### Deposits (`api/v1`)
| Method | Endpoint | Auth | Response |
|--------|----------|------|----------|
| GET | `/rental-requests/{requestId}/deposit` | Required | 200 `DepositDto` |
| PATCH | `/deposits/{depositId}/mark-paid` | Required | 200 `DepositDto` |
| PATCH | `/deposits/{depositId}/refund` | Required | 200 `DepositDto` |

### Reviews (`api/v1`)
| Method | Endpoint | Auth | Response |
|--------|----------|------|----------|
| POST | `/rental-requests/{requestId}/reviews` | Required | 201 `ReviewDto` |

### Notifications (`api/v1/me`)
| Method | Endpoint | Auth | Response |
|--------|----------|------|----------|
| GET | `/notifications` | Required | 200 `PagedResponse<NotificationDto>` |
| GET | `/notifications/unread-count` | Required | 200 `ApiResponse<int>` |
| PATCH | `/notifications/{notificationId}/read` | Required | 204 |
| PATCH | `/notifications/read-all` | Required | 204 |

## SignalR Hub: `/hubs/notifications`

- **Client → Server:** (tự động join group khi connect)
- **Server → Client:** `NotificationReceived` (NotificationDto) — push real-time mỗi khi có notification mới

## Notification Creation Points

| Trigger | Recipient | Type | Reference |
|---------|-----------|------|-----------|
| Create rental request | Listing owner | RentalRequest | request.Id |
| Accept request | Requester | RequestStatus | request.Id |
| Auto-reject | Each other requester | RequestStatus | listing.Id |
| Reject request | Requester | RequestStatus | request.Id |
| Cancel request | Owner | RequestStatus | request.Id |
| Start transaction | Requester | RequestStatus | request.Id |
| Complete transaction | Counterpart | RequestStatus | request.Id |
| Mark deposit paid | Requester | RequestStatus | rentalRequest.Id |
| Refund deposit | Requester | RequestStatus | rentalRequest.Id |
| Create review | Reviewee | Review | review.Id |

Tất cả notification đều skip khi actor == recipient.

## Business Rules Enforced

1. Chỉ request listing Available — không phải Draft/Reserved/InUse/Closed
2. Không thể request listing của chính mình (409)
3. StartDate >= hôm nay, EndDate > StartDate
4. Mỗi user chỉ có 1 active request (Pending/Accepted/InProgress) / listing
5. Chỉ owner mới accept/reject/start
6. Chỉ requester mới cancel
7. Accept → auto-reject các Pending khác cùng listing
8. Cancel từ Accepted → revert listing về Available
9. Start → listing → InUse, tạo Deposit nếu DepositAmount > 0
10. Complete → listing → Available, either party
11. Mark deposit paid chỉ khi status = Pending, owner only
12. Refund deposit chỉ khi status = Paid + rental Completed
13. Review chỉ khi rental Completed
14. Mỗi user chỉ review 1 lần / rental request (unique index)
15. Reputation cập nhật đồng bộ khi tạo review, floor = 0

## Build Status

```
Build succeeded.
    0 Warning(s)
    0 Error(s)
```
