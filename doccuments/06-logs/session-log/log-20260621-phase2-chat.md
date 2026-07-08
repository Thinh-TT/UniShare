# Session Log — Phase 2.5: Chat Realtime

- **Date:** 2026-06-21
- **Người thực hiện:** ThinhTT + Claude (deepseek-v4-pro)
- **Tasks:** `API-CHAT-001` → `API-CHAT-004`
- **Loại:** Implementation

## Tóm Tắt

Hoàn thành toàn bộ 4 task Chat Realtime trong Phase 2 - Backend API Core:

| Task | Mô tả | Kết quả |
|------|-------|---------|
| `API-CHAT-001` | Tạo/mở conversation theo listing | POST `/listings/{id}/conversations` — 201 new / 200 existing |
| `API-CHAT-002` | List/detail conversation | GET `/me/conversations` + GET `/conversations/{id}` |
| `API-CHAT-003` | Message HTTP APIs | GET/POST messages + PATCH mark read |
| `API-CHAT-004` | SignalR `/hubs/chat` | 4 hub methods + 3 server events |

## Files Created (12)

| File | Purpose |
|------|---------|
| `Models/DTOs/Chat/ConversationSummaryDto.cs` | DTO danh sách hội thoại (có UnreadCount, OtherParticipant) |
| `Models/DTOs/Chat/ConversationDetailDto.cs` | DTO chi tiết hội thoại |
| `Models/DTOs/Chat/MessageDto.cs` | DTO tin nhắn |
| `Models/DTOs/Chat/CreateConversationRequest.cs` | Request body tạo conversation |
| `Models/DTOs/Chat/SendMessageRequest.cs` | Request body gửi message |
| `Models/DTOs/Chat/MarkMessagesReadRequest.cs` | Request body đánh dấu đã đọc |
| `Validators/Chat/CreateConversationRequestValidator.cs` | Validate initial message max 2000 |
| `Validators/Chat/SendMessageRequestValidator.cs` | Validate content not empty, max 2000 |
| `Services/Interfaces/IChatService.cs` | Interface 7 methods |
| `Services/ChatService.cs` | Business logic (theo pattern InteractionService) |
| `Hubs/ChatHub.cs` | SignalR hub: JoinConversation, LeaveConversation, SendMessage, MarkAsRead |
| `Controllers/ChatController.cs` | 6 REST endpoints |

## Files Modified (3)

| File | Change |
|------|--------|
| `Data/Configurations/ConversationConfiguration.cs` | Thêm unique composite index `(ListingId, OwnerId, RequesterId)` |
| `Extensions/ServiceCollectionExtensions.cs` | Thêm `AddSignalR()` + `AddScoped<IChatService, ChatService>()` |
| `Program.cs` | Thêm `app.MapHub<ChatHub>("/hubs/chat")` |

## Migration

- **Name:** `20260621162738_AddConversationUniqueConstraint`
- **Nội dung:** `CREATE UNIQUE INDEX [IX_Conversations_ListingId_OwnerId_RequesterId] ON [Conversations] ([ListingId], [OwnerId], [RequesterId])`
- **Status:** Applied thành công

## Quyết Định Kỹ Thuật

### 1. Không dùng ConnectionManager
Không tạo `IConnectionManager` singleton để track user connections. Lý do:
- `IHubContext<ChatHub>` đã đủ để broadcast từ controller (HTTP fallback)
- Hub methods dùng `Clients.Group(conversationId)` để broadcast trong group
- Giảm complexity, tránh race condition với ConcurrentDictionary

### 2. Notification tạo trong Service, không phải trong Hub
Theo đúng pattern từ `InteractionService`: notification được tạo trong `ChatService.SendMessageAsync()` (chỉ khi sender != receiver). Hub chỉ lo realtime delivery, không đụng vào persistence.

### 3. ConversationSummaryDto resolve động OtherParticipant
Trường `OtherParticipantId/Name/AvatarUrl` được resolve dựa trên userId hiện tại:
- Nếu userId == OwnerId → other = Requester
- Ngược lại → other = Owner

Điều này cho phép mỗi user nhìn thấy thông tin của người kia trong danh sách hội thoại.

### 4. UnreadCount batch query
Thay vì N+1 query cho mỗi conversation, dùng batch query:
```csharp
_context.Messages
    .Where(m => conversationIds.Contains(m.ConversationId) && m.Status == Sent && m.SenderId != userId)
    .GroupBy(m => m.ConversationId)
    .Select(g => new { ConversationId = g.Key, Count = g.Count() })
    .ToDictionaryAsync(...)
```

### 5. MessageStatus string-based enum
Giữ nguyên convention lưu enum dưới dạng string trong DB (`.HasConversion<string>()`). `MessageDto.Status` trả về string ("Sent", "Read", "Deleted").

## API Contract

| Method | Endpoint | Auth | Response |
|--------|----------|------|----------|
| POST | `/api/v1/listings/{listingId}/conversations` | Required | 201/200 `ConversationDetailDto` |
| GET | `/api/v1/me/conversations` | Required | 200 `PagedResponse<ConversationSummaryDto>` |
| GET | `/api/v1/conversations/{conversationId}` | Required | 200 `ConversationDetailDto` |
| GET | `/api/v1/conversations/{conversationId}/messages` | Required | 200 `PagedResponse<MessageDto>` |
| POST | `/api/v1/conversations/{conversationId}/messages` | Required | 201 `MessageDto` |
| PATCH | `/api/v1/conversations/{conversationId}/messages/read` | Required | 204 |

## SignalR Hub: `/hubs/chat`

**Client → Server:** JoinConversation, LeaveConversation, SendMessage, MarkAsRead
**Server → Client:** MessageReceived (MessageDto), MessageRead ({conversationId, readByUserId, readAt}), ConversationUpdated ({OwnerSummary, RequesterSummary})

## Business Rules Enforced

1. Một conversation duy nhất / triplet (ListingId, OwnerId, RequesterId) — unique constraint
2. Không thể chat với chính mình (409 Conflict)
3. Chỉ participant mới truy cập conversation/messages (403 Forbidden)
4. Message content 1-2000 ký tự
5. LastMessageAt cập nhật khi gửi message
6. Notification type=Message cho người nhận
7. Mark read chỉ đánh dấu message của người khác
