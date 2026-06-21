# Session Log: Phase 2 - Backend API Core: Tương Tác Cộng Đồng

**Date:** 2026-06-21
**Author:** ThinhTT + Claude Code
**Status:** Completed

---

## Summary

Hoàn thành 3 task Community Interaction (API-INT-001 → API-INT-003): upvote/un-upvote listing, bình luận và reply, soft-delete comment. 6 API endpoints, tự động tạo notification cho chủ bài, idempotent upvote, phân quyền xóa comment (owner/admin).

## Architecture Decisions

### Decision 1: Tách Controller Riêng Cho Interactions

- **What:** Tạo `InteractionsController` với route `[Route("api/v1")]` thay vì thêm endpoint vào `ListingsController`.
- **Why:** Interactions là một module riêng với Swagger group "Interactions" đã định nghĩa sẵn. Việc tách controller giữ cho `ListingsController` không bị phình to và tuân theo cấu trúc module hóa của dự án.
- **Trade-off:** Route trải rộng trên `/listings/{id}/upvote` và `/comments/{id}` — không theo pattern `[controller]` thông thường, nhưng vẫn rõ ràng và không xung đột với các controller khác.

### Decision 2: Idempotent Upvote

- **What:** `PUT /upvote` khi đã upvote trả về `isUpvoted: true` và count hiện tại thay vì ném lỗi. `DELETE /upvote` khi chưa upvote trả về `isUpvoted: false`.
- **Why:** Idempotency là best practice cho REST APIs. Client có thể gọi lại PUT/DELETE an toàn khi không chắc chắn trạng thái hiện tại (vd: network retry). Tránh race condition phía client.
- **Pattern:** Giống với idempotent deactivation trong Admin APIs (log-20260621-phase2-admin).

### Decision 3: CommentDto Phẳng (Không Lồng Replies)

- **What:** `CommentDto` chứa `ParentCommentId` nullable, không có collection `Replies`.
- **Why:** Tránh recursive EF query phức tạp (Include(x => x.Replies).ThenInclude(...)). Client tự build cây từ danh sách phẳng. Pagination đơn giản và hiệu quả hơn — mỗi trang trả về N comment bất kể độ sâu của reply tree.
- **Trade-off:** Client cần thêm logic nhỏ để group replies theo `ParentCommentId`.

### Decision 4: Soft Delete Giảm CommentCount

- **What:** Khi soft-delete comment, decrement `Listing.CommentCount` với guard `Math.Max(0, count - 1)`.
- **Why:** Giữ cho `CommentCount` phản ánh đúng số lượng comment hiển thị (soft-deleted bị lọc bởi global query filter). Giống pattern đã có: tạo comment → tăng count, xóa → giảm count.
- **Guard:** `Math.Max(0, ...)` chống underflow trong edge case race condition.

### Decision 5: Notification Chỉ Gửi Khi Actor ≠ Owner

- **What:** Không tạo notification khi chủ bài tự upvote hoặc tự comment lên bài của mình.
- **Why:** Tránh notification spam vô nghĩa. Người dùng không cần được thông báo về hành động của chính mình.

### Decision 6: Kiểm Tra Listing Status Trước Mọi Tương Tác

- **What:** Helper `ValidateListingActiveAsync` kiểm tra listing tồn tại (global query filter loại soft-deleted) và status không phải Draft/Closed/Hidden.
- **Why:** Tập trung logic kiểm tra vào một chỗ, tránh lặp code. Draft listings chưa public, Closed/Hidden listings không nên nhận thêm tương tác. Reserved và InUse vẫn cho phép comment/upvote vì người dùng có thể quan tâm.
- **Exception:** 404 cho listing không tồn tại/đã xóa, 409 cho listing không ở trạng thái tương tác được.

## Issues & Fixes

Không có lỗi phát sinh — triển khai theo đúng pattern có sẵn, build thành công ngay lần đầu.

## Files Created (9)

| Category | Files |
|----------|-------|
| DTOs | `Models/DTOs/Interactions/{UpvoteResponse,CreateCommentRequest,UpdateCommentRequest,CommentDto}.cs` |
| Validators | `Validators/Interactions/{CreateCommentRequest,UpdateCommentRequest}Validator.cs` |
| Services | `Services/Interfaces/IInteractionService.cs`, `Services/InteractionService.cs` |
| Controllers | `Controllers/InteractionsController.cs` |

## Files Modified (1)

| File | Change |
|------|--------|
| `Extensions/ServiceCollectionExtensions.cs` | Thêm `services.AddScoped<IInteractionService, InteractionService>()` |

## Endpoints Implemented

| Method | Route | Auth | Status |
|--------|-------|------|--------|
| PUT | `/api/v1/listings/{listingId}/upvote` | Required | ✅ |
| DELETE | `/api/v1/listings/{listingId}/upvote` | Required | ✅ |
| GET | `/api/v1/listings/{listingId}/comments` | Optional | ✅ |
| POST | `/api/v1/listings/{listingId}/comments` | Required | ✅ |
| PUT | `/api/v1/comments/{commentId}` | Required | ✅ |
| DELETE | `/api/v1/comments/{commentId}` | Required | ✅ |

## Verification

- ✅ `dotnet build` — 0 errors, 0 warnings
- ⏳ Manual API testing — pending (requires SQL Server running, authenticated users, available listings)
