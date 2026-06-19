# API Specification

## 1. Mục Tiêu Tài Liệu

- Chuẩn hóa contract API giữa backend ASP.NET Core Web API, mobile app Flutter và tester.
- Đồng bộ với `/docs/03-functional/01-functional-requirements.md` và `/docs/02-architecture/01-database-designer.md`.
- Bao phủ toàn bộ endpoint chính cho các use case `FR-001` đến `FR-022`.
- Làm cơ sở để triển khai controller/minimal API, DTO, validation, test case và OpenAPI/Swagger.

## 2. Quy Ước Chung

### 2.1. Base URL và versioning

```text
Base URL: /api/v1
SignalR Hub: /hubs/chat
```

Quy ước version API dùng prefix `/api/v1` để có thể mở rộng sang `/api/v2` khi thay đổi contract lớn.

### 2.2. Format dữ liệu

- Request body: `application/json`, trừ API upload ảnh dùng `multipart/form-data`.
- Response body: `application/json`.
- Thời gian: ISO 8601, lưu backend bằng `DATETIME2`.
- Id: `GUID`/`UNIQUEIDENTIFIER`, format string.
- Tiền tệ: số thập phân, đơn vị mặc định là VND.
- Enum trả về dạng string để frontend dễ đọc và debug.

Ví dụ enum:

```json
{
  "listingType": "Rent",
  "listingStatus": "Available",
  "requestStatus": "Pending",
  "depositStatus": "Paid"
}
```

### 2.3. Authentication và authorization

API dùng JWT Bearer token cho mobile app.

```http
Authorization: Bearer {accessToken}
```

Quy ước quyền:

- `[AllowAnonymous]`: đăng ký, đăng nhập, xem danh sách bài đăng, xem chi tiết bài đăng, xem dữ liệu nền public.
- `[Authorize]`: hồ sơ cá nhân, tạo/sửa bài đăng, upvote, comment, chat, yêu cầu thuê/mượn, đánh giá, thông báo.
- `[Authorize(Roles = "Admin")]`: quản lý dữ liệu nền và thao tác quản trị.

Nguyên tắc authorization:

- Kiểm tra quyền ở boundary của endpoint.
- Kiểm tra ownership trong service: chủ bài đăng, chủ hội thoại, người gửi yêu cầu, người nhận thông báo.
- Không trả dữ liệu riêng tư của người dùng khác.

### 2.4. Response wrapper

Response thành công một object:

```json
{
  "data": {},
  "message": "Success"
}
```

Response danh sách phân trang:

```json
{
  "items": [],
  "page": 1,
  "pageSize": 20,
  "totalItems": 125,
  "totalPages": 7
}
```

Response lỗi dùng ProblemDetails-compatible shape:

```json
{
  "type": "https://unishare/errors/validation",
  "title": "Validation failed",
  "status": 400,
  "detail": "One or more validation errors occurred.",
  "errors": {
    "title": ["Title is required."]
  }
}
```

### 2.5. Status code chuẩn

| Status | Khi sử dụng |
| --- | --- |
| `200 OK` | Lấy dữ liệu hoặc cập nhật thành công |
| `201 Created` | Tạo resource thành công |
| `204 No Content` | Xóa mềm, hủy, đánh dấu đã đọc thành công và không cần body |
| `400 Bad Request` | Request sai format, dữ liệu không hợp lệ |
| `401 Unauthorized` | Chưa đăng nhập hoặc token không hợp lệ |
| `403 Forbidden` | Đã đăng nhập nhưng không có quyền |
| `404 Not Found` | Resource không tồn tại hoặc không được phép thấy |
| `409 Conflict` | Dữ liệu trùng hoặc trạng thái nghiệp vụ xung đột |
| `422 Unprocessable Entity` | Dữ liệu đúng format nhưng vi phạm business rule |
| `500 Internal Server Error` | Lỗi hệ thống không mong muốn |

### 2.6. Query phân trang và sắp xếp

Các API danh sách dùng query chung:

| Query | Kiểu | Mặc định | Ghi chú |
| --- | --- | --- | --- |
| `page` | `int` | `1` | Bắt đầu từ 1 |
| `pageSize` | `int` | `20` | Tối đa đề xuất 50 |
| `sortBy` | `string` | tùy endpoint | Ví dụ `createdAt`, `price`, `upvoteCount` |
| `sortDirection` | `string` | `desc` | `asc` hoặc `desc` |

## 3. DTO Dùng Chung

### 3.1. `UserSummaryDto`

```json
{
  "id": "guid",
  "fullName": "Nguyen Van A",
  "avatarUrl": "https://...",
  "schoolName": "UIT",
  "areaName": "Thu Duc",
  "reputationScore": 100.0,
  "totalReviews": 0
}
```

### 3.2. `ListingSummaryDto`

```json
{
  "id": "guid",
  "title": "Máy tính Casio FX-580VN X",
  "coverImageUrl": "https://...",
  "listingType": "Rent",
  "status": "Available",
  "pricePerDay": 10000,
  "depositAmount": 100000,
  "categoryName": "Máy tính cầm tay",
  "schoolName": "UIT",
  "areaName": "Thu Duc",
  "owner": {},
  "upvoteCount": 12,
  "commentCount": 3,
  "createdAt": "2026-06-19T08:30:00Z"
}
```

### 3.3. `NotificationDto`

```json
{
  "id": "guid",
  "type": "Message",
  "title": "Tin nhắn mới",
  "body": "Bạn có tin nhắn mới về bài đăng Máy tính Casio.",
  "referenceId": "guid",
  "referenceType": "Conversation",
  "isRead": false,
  "createdAt": "2026-06-19T08:30:00Z",
  "readAt": null
}
```

## 4. API Authentication và Users

### 4.1. Đăng ký tài khoản

```http
POST /api/v1/auth/register
```

Use case: `FR-001`

Request:

```json
{
  "email": "student@example.com",
  "phoneNumber": "0900000000",
  "password": "P@ssword123",
  "fullName": "Nguyen Van A"
}
```

Response `201 Created`:

```json
{
  "data": {
    "userId": "guid",
    "email": "student@example.com",
    "fullName": "Nguyen Van A",
    "reputationScore": 100.0
  },
  "message": "Account created successfully"
}
```

Validation/business rules:

- Email bắt buộc unique nếu có nhập.
- Số điện thoại unique nếu có nhập.
- Mật khẩu phải đạt yêu cầu bảo mật.
- `ReputationScore` mặc định `100.00`, `TotalReviews` mặc định `0`.

### 4.2. Đăng nhập

```http
POST /api/v1/auth/login
```

Use case: `FR-002`

Request:

```json
{
  "login": "student@example.com",
  "password": "P@ssword123"
}
```

Response `200 OK`:

```json
{
  "data": {
    "accessToken": "jwt",
    "refreshToken": "refresh-token",
    "expiresIn": 3600,
    "user": {}
  },
  "message": "Login successfully"
}
```

### 4.3. Làm mới token

```http
POST /api/v1/auth/refresh-token
```

Use case: `FR-002`

Request:

```json
{
  "refreshToken": "refresh-token"
}
```

Response `200 OK`: trả access token mới.

### 4.4. Đăng xuất

```http
POST /api/v1/auth/logout
```

Use case: `FR-002`

Auth: Required.

Response `204 No Content`.

### 4.5. Xem hồ sơ cá nhân

```http
GET /api/v1/users/me
```

Use case: `FR-003`

Auth: Required.

Response `200 OK`:

```json
{
  "data": {
    "id": "guid",
    "email": "student@example.com",
    "phoneNumber": "0900000000",
    "fullName": "Nguyen Van A",
    "avatarUrl": "https://...",
    "schoolId": "guid",
    "schoolName": "UIT",
    "areaId": "guid",
    "areaName": "Thu Duc",
    "reputationScore": 100.0,
    "totalReviews": 0,
    "isVerified": false
  },
  "message": "Success"
}
```

### 4.6. Cập nhật hồ sơ cá nhân

```http
PUT /api/v1/users/me
```

Use case: `FR-003`

Auth: Required.

Request:

```json
{
  "fullName": "Nguyen Van A",
  "phoneNumber": "0900000000",
  "avatarUrl": "https://...",
  "schoolId": "guid",
  "areaId": "guid"
}
```

Response `200 OK`: trả profile sau cập nhật.

### 4.7. Xem hồ sơ công khai

```http
GET /api/v1/users/{userId}
```

Use case: `FR-004`

Auth: Optional.

Response `200 OK`: trả `UserSummaryDto` và danh sách review gần nhất nếu cần.

## 5. API Listings

### 5.1. Xem danh sách bài đăng

```http
GET /api/v1/listings
```

Use case: `FR-009`, `FR-010`

Auth: Optional.

Query:

| Query | Kiểu | Ghi chú |
| --- | --- | --- |
| `keyword` | `string` | Tìm theo tiêu đề, mô tả |
| `categoryId` | `guid` | Lọc theo loại đồ |
| `tag` | `string` | Lọc theo tag slug/name |
| `schoolId` | `guid` | Lọc theo trường |
| `areaId` | `guid` | Lọc theo khu vực |
| `listingType` | `string` | `Rent` hoặc `Borrow` |
| `minPrice` | `decimal` | Giá thấp nhất |
| `maxPrice` | `decimal` | Giá cao nhất |
| `page` | `int` | Phân trang |
| `pageSize` | `int` | Phân trang |
| `sortBy` | `string` | `createdAt`, `pricePerDay`, `upvoteCount` |

Response `200 OK`: trả danh sách `ListingSummaryDto`.

Business rules:

- Chỉ trả bài đăng `Status = Available` và `DeletedAt IS NULL`.
- Khách chưa đăng nhập được gọi API này.

### 5.2. Xem chi tiết bài đăng

```http
GET /api/v1/listings/{listingId}
```

Use case: `FR-009`

Auth: Optional.

Response `200 OK`:

```json
{
  "data": {
    "id": "guid",
    "title": "Máy tính Casio FX-580VN X",
    "description": "Máy còn mới, phù hợp thi học kỳ.",
    "listingType": "Rent",
    "status": "Available",
    "pricePerDay": 10000,
    "depositAmount": 100000,
    "conditionNote": "Còn hộp, pin tốt",
    "category": {
      "id": "guid",
      "name": "Máy tính cầm tay"
    },
    "school": {
      "id": "guid",
      "name": "UIT"
    },
    "area": {
      "id": "guid",
      "name": "Thu Duc"
    },
    "tags": ["casio", "fx580"],
    "images": [],
    "owner": {},
    "viewCount": 10,
    "upvoteCount": 2,
    "commentCount": 1,
    "createdAt": "2026-06-19T08:30:00Z",
    "updatedAt": "2026-06-19T08:30:00Z"
  },
  "message": "Success"
}
```

### 5.3. Tạo bài đăng

```http
POST /api/v1/listings
```

Use case: `FR-005`, `FR-008`

Auth: Required.

Request:

```json
{
  "title": "Máy tính Casio FX-580VN X",
  "description": "Cho thuê theo ngày.",
  "categoryId": "guid",
  "schoolId": "guid",
  "areaId": "guid",
  "listingType": "Rent",
  "pricePerDay": 10000,
  "depositAmount": 100000,
  "conditionNote": "Còn mới",
  "tags": ["casio", "may-tinh"]
}
```

Response `201 Created`: trả chi tiết bài đăng.

Business rules:

- User phải active.
- `title`, `description`, `categoryId`, `listingType` bắt buộc.
- Nếu `listingType = Borrow` thì `pricePerDay = 0`.
- `pricePerDay` và `depositAmount` không được âm.
- Category, school, area phải active nếu được chọn.

### 5.4. Cập nhật bài đăng

```http
PUT /api/v1/listings/{listingId}
```

Use case: `FR-006`, `FR-008`

Auth: Required, owner only.

Request: giống API tạo bài đăng.

Response `200 OK`: trả chi tiết bài đăng sau cập nhật.

Business rules:

- Chỉ chủ bài đăng được cập nhật.
- Không cho cập nhật/xóa bài nếu đang có giao dịch `InProgress`, trừ các trường không ảnh hưởng giao dịch.

### 5.5. Đóng bài đăng

```http
PATCH /api/v1/listings/{listingId}/close
```

Use case: `FR-006`

Auth: Required, owner only.

Response `200 OK`: bài đăng chuyển `Status = Closed`.

### 5.6. Xóa mềm bài đăng

```http
DELETE /api/v1/listings/{listingId}
```

Use case: `FR-006`

Auth: Required, owner only.

Response `204 No Content`.

Business rules:

- Set `DeletedAt`, không xóa cứng.
- Bài đăng đã xóa mềm không xuất hiện trong tìm kiếm công khai.

### 5.7. Danh sách bài đăng của tôi

```http
GET /api/v1/me/listings
```

Use case: `FR-006`

Auth: Required.

Query: `status`, `page`, `pageSize`.

Response `200 OK`: danh sách bài đăng của người dùng hiện tại.

## 6. API Listing Images

### 6.1. Upload ảnh bài đăng

```http
POST /api/v1/listings/{listingId}/images
Content-Type: multipart/form-data
```

Use case: `FR-007`

Auth: Required, owner only.

Form data:

| Field | Kiểu | Ghi chú |
| --- | --- | --- |
| `files` | `file[]` | Một hoặc nhiều ảnh |
| `isCover` | `bool` | Có đặt ảnh đầu tiên làm cover không |

Response `201 Created`: trả danh sách ảnh đã upload.

Business rules:

- Mỗi bài đăng tối thiểu 1 ảnh, tối đa 10 ảnh.
- Chỉ 1 ảnh có `IsCover = true`.
- Chỉ cho upload định dạng ảnh hợp lệ.

### 6.2. Đổi ảnh cover

```http
PATCH /api/v1/listings/{listingId}/images/{imageId}/cover
```

Use case: `FR-007`

Auth: Required, owner only.

Response `200 OK`.

### 6.3. Sắp xếp ảnh

```http
PUT /api/v1/listings/{listingId}/images/order
```

Use case: `FR-007`

Auth: Required, owner only.

Request:

```json
{
  "imageOrders": [
    {
      "imageId": "guid",
      "displayOrder": 1
    }
  ]
}
```

Response `200 OK`.

### 6.4. Xóa ảnh

```http
DELETE /api/v1/listings/{listingId}/images/{imageId}
```

Use case: `FR-007`

Auth: Required, owner only.

Response `204 No Content`.

## 7. API Tags, Categories, Schools, Areas

### 7.1. Lấy danh sách category

```http
GET /api/v1/categories
```

Use case: `FR-008`, `FR-010`, `FR-022`

Auth: Optional.

Response `200 OK`: danh sách category active.

### 7.2. Lấy danh sách tag

```http
GET /api/v1/tags
```

Use case: `FR-008`, `FR-010`, `FR-022`

Auth: Optional.

Query: `keyword`, `page`, `pageSize`.

Response `200 OK`: danh sách tag.

### 7.3. Lấy danh sách trường

```http
GET /api/v1/schools
```

Use case: `FR-003`, `FR-008`, `FR-010`, `FR-022`

Auth: Optional.

Response `200 OK`: danh sách school active.

### 7.4. Lấy danh sách khu vực

```http
GET /api/v1/areas
```

Use case: `FR-003`, `FR-008`, `FR-010`, `FR-022`

Auth: Optional.

Query: `city`.

Response `200 OK`: danh sách area active.

### 7.5. Admin quản lý dữ liệu nền

```http
POST /api/v1/admin/categories
PUT /api/v1/admin/categories/{categoryId}
PATCH /api/v1/admin/categories/{categoryId}/deactivate

POST /api/v1/admin/schools
PUT /api/v1/admin/schools/{schoolId}
PATCH /api/v1/admin/schools/{schoolId}/deactivate

POST /api/v1/admin/areas
PUT /api/v1/admin/areas/{areaId}
PATCH /api/v1/admin/areas/{areaId}/deactivate
```

Use case: `FR-022`

Auth: Required, admin only.

Business rules:

- Không xóa cứng dữ liệu nền đã được tham chiếu.
- Category/tag slug phải unique.
- Chỉ dữ liệu `IsActive = true` được hiển thị cho người dùng thường.

## 8. API Upvotes và Comments

### 8.1. Upvote hoặc hủy upvote bài đăng

```http
PUT /api/v1/listings/{listingId}/upvote
DELETE /api/v1/listings/{listingId}/upvote
```

Use case: `FR-011`

Auth: Required.

Response `200 OK`:

```json
{
  "data": {
    "listingId": "guid",
    "isUpvoted": true,
    "upvoteCount": 13
  },
  "message": "Success"
}
```

Business rules:

- Mỗi user chỉ có một upvote trên một bài đăng.
- Không upvote bài đăng đã xóa, ẩn hoặc đóng.
- Khi upvote mới, tạo notification cho chủ bài đăng.

### 8.2. Lấy bình luận của bài đăng

```http
GET /api/v1/listings/{listingId}/comments
```

Use case: `FR-012`

Auth: Optional.

Query: `page`, `pageSize`.

Response `200 OK`: danh sách bình luận.

### 8.3. Tạo bình luận

```http
POST /api/v1/listings/{listingId}/comments
```

Use case: `FR-012`

Auth: Required.

Request:

```json
{
  "content": "Bạn còn máy này không?",
  "parentCommentId": null
}
```

Response `201 Created`: trả bình luận vừa tạo.

Business rules:

- `content` không được rỗng.
- Nếu có `parentCommentId`, bình luận cha phải thuộc cùng bài đăng.
- Tạo notification cho chủ bài đăng hoặc người được phản hồi.

### 8.4. Cập nhật bình luận

```http
PUT /api/v1/comments/{commentId}
```

Use case: `FR-012`

Auth: Required, owner only.

Request:

```json
{
  "content": "Nội dung đã sửa"
}
```

Response `200 OK`.

### 8.5. Xóa mềm bình luận

```http
DELETE /api/v1/comments/{commentId}
```

Use case: `FR-012`

Auth: Required, owner or admin.

Response `204 No Content`.

## 9. API Conversations và Messages

### 9.1. Tạo hoặc mở hội thoại theo bài đăng

```http
POST /api/v1/listings/{listingId}/conversations
```

Use case: `FR-013`

Auth: Required.

Response `200 OK` hoặc `201 Created`:

```json
{
  "data": {
    "id": "guid",
    "listingId": "guid",
    "owner": {},
    "requester": {},
    "lastMessageAt": null,
    "createdAt": "2026-06-19T08:30:00Z"
  },
  "message": "Conversation ready"
}
```

Business rules:

- Không tạo hội thoại với chính mình.
- Một cặp `ListingId`, `OwnerId`, `RequesterId` chỉ có một hội thoại.

### 9.2. Danh sách hội thoại của tôi

```http
GET /api/v1/me/conversations
```

Use case: `FR-013`

Auth: Required.

Query: `page`, `pageSize`.

Response `200 OK`: danh sách hội thoại của user hiện tại.

### 9.3. Xem chi tiết hội thoại

```http
GET /api/v1/conversations/{conversationId}
```

Use case: `FR-013`, `FR-014`

Auth: Required, participant only.

Response `200 OK`: thông tin hội thoại.

### 9.4. Lấy tin nhắn trong hội thoại

```http
GET /api/v1/conversations/{conversationId}/messages
```

Use case: `FR-014`

Auth: Required, participant only.

Query: `page`, `pageSize`, `before`.

Response `200 OK`: danh sách tin nhắn, mới nhất hoặc theo cursor.

### 9.5. Gửi tin nhắn qua HTTP

```http
POST /api/v1/conversations/{conversationId}/messages
```

Use case: `FR-014`

Auth: Required, participant only.

Request:

```json
{
  "content": "Mình muốn thuê vào cuối tuần này."
}
```

Response `201 Created`: trả message đã lưu.

Ghi chú:

- Endpoint HTTP dùng làm fallback hoặc lưu tin nhắn.
- Realtime delivery chính đi qua SignalR hub `/hubs/chat`.

### 9.6. Đánh dấu tin nhắn đã đọc

```http
PATCH /api/v1/conversations/{conversationId}/messages/read
```

Use case: `FR-014`

Auth: Required, participant only.

Request:

```json
{
  "lastReadMessageId": "guid"
}
```

Response `204 No Content`.

## 10. SignalR Chat Hub

Endpoint:

```text
/hubs/chat
```

Auth: Required bằng JWT.

### 10.1. Client gọi server

| Method | Payload | Ý nghĩa |
| --- | --- | --- |
| `JoinConversation` | `{ "conversationId": "guid" }` | Vào group hội thoại |
| `LeaveConversation` | `{ "conversationId": "guid" }` | Rời group hội thoại |
| `SendMessage` | `{ "conversationId": "guid", "content": "..." }` | Gửi tin nhắn realtime |
| `MarkAsRead` | `{ "conversationId": "guid", "lastReadMessageId": "guid" }` | Đánh dấu đã đọc |

### 10.2. Server gửi client

| Event | Payload | Ý nghĩa |
| --- | --- | --- |
| `MessageReceived` | `MessageDto` | Có tin nhắn mới |
| `MessageRead` | `{ "conversationId": "guid", "readerId": "guid", "lastReadMessageId": "guid" }` | Tin nhắn đã đọc |
| `NotificationReceived` | `NotificationDto` | Có thông báo mới |
| `ConversationUpdated` | `ConversationDto` | Cập nhật hội thoại |

Business rules:

- Hub chỉ xử lý giao tiếp realtime, business logic nằm trong service.
- User chỉ được join group hội thoại mà mình là participant.
- Khi gửi tin nhắn, vẫn phải lưu vào `Messages` trước khi push realtime.

## 11. API Rental Requests và Deposits

### 11.1. Gửi yêu cầu thuê/mượn

```http
POST /api/v1/listings/{listingId}/rental-requests
```

Use case: `FR-015`

Auth: Required.

Request:

```json
{
  "startDate": "2026-06-20T00:00:00Z",
  "endDate": "2026-06-22T00:00:00Z",
  "message": "Mình muốn thuê để thi cuối kỳ."
}
```

Response `201 Created`:

```json
{
  "data": {
    "id": "guid",
    "listingId": "guid",
    "requesterId": "guid",
    "ownerId": "guid",
    "status": "Pending",
    "totalPrice": 30000,
    "depositAmount": 100000,
    "depositStatus": "Pending",
    "createdAt": "2026-06-19T08:30:00Z"
  },
  "message": "Rental request created"
}
```

Business rules:

- Không gửi yêu cầu cho bài đăng của chính mình.
- Chỉ gửi yêu cầu khi bài đăng `Available`.
- Không tạo nhiều yêu cầu `Pending` cho cùng một bài đăng từ cùng user.
- `startDate <= endDate`.

### 11.2. Danh sách yêu cầu của tôi

```http
GET /api/v1/me/rental-requests
```

Use case: `FR-017`

Auth: Required.

Query:

| Query | Kiểu | Ghi chú |
| --- | --- | --- |
| `role` | `string` | `Requester` hoặc `Owner` |
| `status` | `string` | Lọc trạng thái |
| `page` | `int` | Phân trang |
| `pageSize` | `int` | Phân trang |

Response `200 OK`: danh sách yêu cầu liên quan đến user.

### 11.3. Xem chi tiết yêu cầu

```http
GET /api/v1/rental-requests/{requestId}
```

Use case: `FR-017`

Auth: Required, owner/requester only.

Response `200 OK`: chi tiết yêu cầu, bài đăng, người gửi, chủ bài và deposit nếu có.

### 11.4. Chấp nhận yêu cầu

```http
PATCH /api/v1/rental-requests/{requestId}/accept
```

Use case: `FR-016`

Auth: Required, listing owner only.

Response `200 OK`: yêu cầu chuyển `Accepted`, bài đăng chuyển `Reserved` hoặc `InUse`.

Business rules:

- Chỉ chủ bài đăng được chấp nhận.
- Chỉ yêu cầu `Pending` được chấp nhận.
- MVP đề xuất tự động từ chối các yêu cầu `Pending` khác của cùng bài đăng.

### 11.5. Từ chối yêu cầu

```http
PATCH /api/v1/rental-requests/{requestId}/reject
```

Use case: `FR-016`

Auth: Required, listing owner only.

Request:

```json
{
  "reason": "Đồ đã có người thuê."
}
```

Response `200 OK`: yêu cầu chuyển `Rejected`.

### 11.6. Hủy yêu cầu

```http
PATCH /api/v1/rental-requests/{requestId}/cancel
```

Use case: `FR-016`

Auth: Required, requester only.

Request:

```json
{
  "reason": "Mình không cần thuê nữa."
}
```

Response `200 OK`: yêu cầu chuyển `Cancelled`.

### 11.7. Bắt đầu giao dịch

```http
PATCH /api/v1/rental-requests/{requestId}/start
```

Use case: `FR-017`

Auth: Required, owner/requester depending on policy.

Response `200 OK`: yêu cầu chuyển `InProgress`, bài đăng chuyển `InUse`.

### 11.8. Hoàn tất giao dịch

```http
PATCH /api/v1/rental-requests/{requestId}/complete
```

Use case: `FR-019`

Auth: Required, owner/requester only.

Response `200 OK`: yêu cầu chuyển `Completed`.

Business rules:

- Chỉ hoàn tất yêu cầu `Accepted` hoặc `InProgress`.
- Sau khi hoàn tất, bài đăng có thể chuyển `Available` hoặc `Closed`.
- Sau khi hoàn tất, hai bên được quyền đánh giá.

### 11.9. Xem trạng thái đặt cọc

```http
GET /api/v1/rental-requests/{requestId}/deposit
```

Use case: `FR-018`

Auth: Required, owner/requester only.

Response `200 OK`: thông tin deposit nếu có.

### 11.10. Ghi nhận thanh toán đặt cọc

```http
PATCH /api/v1/deposits/{depositId}/mark-paid
```

Use case: `FR-018`

Auth: Required. MVP có thể giới hạn owner/admin hoặc payment callback.

Request:

```json
{
  "paymentProvider": "Manual",
  "providerTransactionId": "MANUAL-001"
}
```

Response `200 OK`: deposit chuyển `Paid`.

### 11.11. Hoàn cọc

```http
PATCH /api/v1/deposits/{depositId}/refund
```

Use case: `FR-018`, `FR-019`

Auth: Required, owner/admin depending on policy.

Response `200 OK`: deposit chuyển `Refunded`.

Business rules:

- Chỉ hoàn cọc khi trạng thái hiện tại là `Paid`.

## 12. API Reviews

### 12.1. Tạo đánh giá sau giao dịch

```http
POST /api/v1/rental-requests/{requestId}/reviews
```

Use case: `FR-020`

Auth: Required, owner/requester only.

Request:

```json
{
  "revieweeId": "guid",
  "rating": 5,
  "comment": "Bạn giao đồ đúng hẹn, đồ dùng tốt."
}
```

Response `201 Created`:

```json
{
  "data": {
    "id": "guid",
    "rentalRequestId": "guid",
    "reviewerId": "guid",
    "revieweeId": "guid",
    "rating": 5,
    "comment": "Bạn giao đồ đúng hẹn, đồ dùng tốt.",
    "reputationDelta": 2.0,
    "createdAt": "2026-06-19T08:30:00Z"
  },
  "message": "Review created"
}
```

Business rules:

- Chỉ đánh giá khi yêu cầu `Completed`.
- Mỗi người chỉ đánh giá người còn lại một lần trong cùng giao dịch.
- `rating` từ 1 đến 5.
- Không tự đánh giá chính mình.
- Sau khi tạo review, cập nhật `Users.ReputationScore` và `TotalReviews`.

### 12.2. Lấy đánh giá của người dùng

```http
GET /api/v1/users/{userId}/reviews
```

Use case: `FR-004`, `FR-020`

Auth: Optional.

Query: `page`, `pageSize`.

Response `200 OK`: danh sách review user đã nhận.

## 13. API Notifications

### 13.1. Danh sách thông báo của tôi

```http
GET /api/v1/me/notifications
```

Use case: `FR-021`

Auth: Required.

Query:

| Query | Kiểu | Ghi chú |
| --- | --- | --- |
| `isRead` | `bool` | Lọc đã đọc/chưa đọc |
| `type` | `string` | Lọc loại thông báo |
| `page` | `int` | Phân trang |
| `pageSize` | `int` | Phân trang |

Response `200 OK`: danh sách `NotificationDto`.

### 13.2. Đếm thông báo chưa đọc

```http
GET /api/v1/me/notifications/unread-count
```

Use case: `FR-021`

Auth: Required.

Response `200 OK`:

```json
{
  "data": {
    "unreadCount": 5
  },
  "message": "Success"
}
```

### 13.3. Đánh dấu một thông báo đã đọc

```http
PATCH /api/v1/me/notifications/{notificationId}/read
```

Use case: `FR-021`

Auth: Required, receiver only.

Response `204 No Content`.

### 13.4. Đánh dấu tất cả thông báo đã đọc

```http
PATCH /api/v1/me/notifications/read-all
```

Use case: `FR-021`

Auth: Required.

Response `204 No Content`.

## 14. Mapping Endpoint Với Use Case

| Use case | Endpoint chính |
| --- | --- |
| `FR-001` | `POST /auth/register` |
| `FR-002` | `POST /auth/login`, `POST /auth/refresh-token`, `POST /auth/logout` |
| `FR-003` | `GET /users/me`, `PUT /users/me`, `GET /schools`, `GET /areas` |
| `FR-004` | `GET /users/{userId}`, `GET /users/{userId}/reviews` |
| `FR-005` | `POST /listings` |
| `FR-006` | `PUT /listings/{listingId}`, `PATCH /listings/{listingId}/close`, `DELETE /listings/{listingId}`, `GET /me/listings` |
| `FR-007` | `POST /listings/{listingId}/images`, `PATCH /listings/{listingId}/images/{imageId}/cover`, `PUT /listings/{listingId}/images/order`, `DELETE /listings/{listingId}/images/{imageId}` |
| `FR-008` | `GET /categories`, `GET /tags`, `GET /schools`, `GET /areas`, `POST /listings`, `PUT /listings/{listingId}` |
| `FR-009` | `GET /listings`, `GET /listings/{listingId}` |
| `FR-010` | `GET /listings`, `GET /categories`, `GET /tags`, `GET /schools`, `GET /areas` |
| `FR-011` | `PUT /listings/{listingId}/upvote`, `DELETE /listings/{listingId}/upvote` |
| `FR-012` | `GET /listings/{listingId}/comments`, `POST /listings/{listingId}/comments`, `PUT /comments/{commentId}`, `DELETE /comments/{commentId}` |
| `FR-013` | `POST /listings/{listingId}/conversations`, `GET /me/conversations`, `GET /conversations/{conversationId}` |
| `FR-014` | `GET /conversations/{conversationId}/messages`, `POST /conversations/{conversationId}/messages`, `PATCH /conversations/{conversationId}/messages/read`, `/hubs/chat` |
| `FR-015` | `POST /listings/{listingId}/rental-requests` |
| `FR-016` | `PATCH /rental-requests/{requestId}/accept`, `PATCH /rental-requests/{requestId}/reject`, `PATCH /rental-requests/{requestId}/cancel` |
| `FR-017` | `GET /me/rental-requests`, `GET /rental-requests/{requestId}`, `PATCH /rental-requests/{requestId}/start` |
| `FR-018` | `GET /rental-requests/{requestId}/deposit`, `PATCH /deposits/{depositId}/mark-paid`, `PATCH /deposits/{depositId}/refund` |
| `FR-019` | `PATCH /rental-requests/{requestId}/complete`, `PATCH /deposits/{depositId}/refund` |
| `FR-020` | `POST /rental-requests/{requestId}/reviews`, `GET /users/{userId}/reviews` |
| `FR-021` | `GET /me/notifications`, `GET /me/notifications/unread-count`, `PATCH /me/notifications/{notificationId}/read`, `PATCH /me/notifications/read-all` |
| `FR-022` | `POST/PUT/PATCH /admin/categories`, `POST/PUT/PATCH /admin/schools`, `POST/PUT/PATCH /admin/areas` |

## 15. Ghi Chú Triển Khai ASP.NET Core

- Có thể triển khai bằng controller-based API hoặc Minimal API, nhưng nên thống nhất một style trong cùng project.
- DTO request/response phải tách khỏi Entity Framework entities.
- Validation nên đặt ở DTO/service boundary, không dựa hoàn toàn vào database constraint.
- API lỗi nên trả ProblemDetails để frontend xử lý thống nhất.
- Các endpoint cần ownership phải kiểm tra trong service, ví dụ `listing.OwnerId == currentUserId`.
- SignalR hub dùng cho push realtime, còn lưu dữ liệu vẫn đi qua service và database transaction.
- File upload nên kiểm tra loại file, kích thước file và lưu đường dẫn vào `ListingImages`.
- Swagger/OpenAPI nên group theo module: `Auth`, `Users`, `Listings`, `Interactions`, `Chat`, `RentalRequests`, `Reviews`, `Notifications`, `Admin`.
