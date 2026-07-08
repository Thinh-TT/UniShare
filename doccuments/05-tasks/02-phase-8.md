# Phase 8 - Sửa Đăng Nhập, Upload Avatar, Notification Badge & Deep Link

## 1. Mục Tiêu

Cải thiện trải nghiệm người dùng với 4 tính năng:

1. **Lưu tài khoản sau khi đóng app** - Đăng nhập 1 lần, mở lại app tự động vào Home không cần đăng nhập lại
2. **Upload avatar và đồng bộ** - Cho phép chọn/chụp ảnh đại diện, hiển thị đồng bộ trên mọi màn hình
3. **Số đỏ thông báo chưa đọc** - Hiển thị badge số thông báo chưa đọc ở icon thông báo
4. **Nhấn thông báo điều hướng đến màn hình liên quan** - Tap thông báo (trong list hoặc real-time) đi đến đúng màn hình

## 2. Phân Tích Hiện Trạng

| Tính năng | Hiện trạng | Vấn đề |
|-----------|-----------|--------|
| Lưu tài khoản | Đã có `tryAutoLogin()` + `FlutterSecureStorage` | 3 bug: không fallback storage, race condition `didChangeDependencies`, token rỗng vẫn set `AuthAuthenticated` |
| Upload avatar | Backend: chưa có endpoint upload avatar. Flutter: `EditProfileScreen` hiển thị avatar read-only | Cần làm mới cả backend + Flutter |
| Notification badge | `HomeScreen` đã có bell + badge. `unreadCountProvider` đã fetch count | Bug parse API: backend trả `{data: <int>}` nhưng code parse `data` thành `Map`. Chỉ có badge ở HomeScreen |
| Notification deep link | `NotificationsScreen._onTapNotification()` đã navigate theo `referenceType` | Real-time không hoạt động: listener `NotificationReceived` đăng ký trên `/hubs/chat` nhưng notification push từ `/hubs/notifications` → dead code |

## 3. Task Board

### 3.1. Sửa Login Persistence (Lưu tài khoản)

| ID | Task | Status | Priority | Dependency | Definition of Done |
|----|------|--------|----------|------------|-------------------|
| `P8-AUTH-001` | Thêm `SharedPreferences` fallback storage trong `TokenStorage` | `[ ]` | P0 | N/A | `saveTokens` ghi cả 2 storage, `getAccessToken` fallback khi secure storage fail |
| `P8-AUTH-002` | Sửa race condition `SplashScreen` (thay `didChangeDependencies` bằng `initState` + `addPostFrameCallback`) | `[ ]` | P0 | N/A | Không double-fire navigation, thêm `mounted` check |
| `P8-AUTH-003` | Validate token sau refresh: token rỗng → `AuthUnauthenticated` | `[ ]` | P0 | `P8-AUTH-001` | Sau `tryAutoLogin()` nếu access token null → redirect login |
| `P8-AUTH-004` | Thêm debug log và error callback cho `tryAutoLogin()` | `[ ]` | P1 | `P8-AUTH-001` | Log được lỗi storage khi debug |

### 3.2. Upload Avatar (Ảnh đại diện)

#### 3.2.1. Backend

| ID | Task | Status | Priority | Dependency | Definition of Done |
|----|------|--------|----------|------------|-------------------|
| `P8-AV-BE-01` | Tạo `IAvatarService` và `AvatarService` (validate file, lưu `wwwroot/uploads/avatars/`, xóa file cũ, update DB) | `[ ]` | P0 | N/A | Upload ảnh .jpg/.png/.webp ≤5MB thành công, file cũ bị xóa |
| `P8-AV-BE-02` | Thêm endpoint `POST /api/v1/users/me/avatar` trong `UsersController` | `[ ]` | P0 | `P8-AV-BE-01` | Endpoint nhận `multipart/form-data`, trả URL avatar mới |
| `P8-AV-BE-03` | Đăng ký `IAvatarService` trong DI (`ServiceCollectionExtensions`) | `[ ]` | P0 | `P8-AV-BE-01` | Service được inject đúng |

#### 3.2.2. Flutter

| ID | Task | Status | Priority | Dependency | Definition of Done |
|----|------|--------|----------|------------|-------------------|
| `P8-AV-FE-01` | Thêm `uploadAvatar()` trong `UserApi` và `UserRepository` | `[ ]` | P0 | `P8-AV-BE-02` | Gọi API multipart upload, nhận URL |
| `P8-AV-FE-02` | Thêm image picker vào `EditProfileScreen`: avatar + camera icon overlay | `[ ]` | P0 | `P8-AV-FE-01` | Chọn ảnh từ gallery/camera, resize 1024px, upload, invalidate `userProfileProvider` |
| `P8-AV-FE-03` | Kiểm tra đồng bộ avatar: `UserAvatar` widget trên Home, Profile, Comments, Chat hiển thị ảnh mới | `[ ]` | P0 | `P8-AV-FE-02` | Sau upload, tất cả màn hình reflect avatar mới (qua `userProfileProvider`) |
| `P8-AV-FE-04` | Thêm endpoint `uploadAvatar` vào `api_endpoints.dart` | `[ ]` | P0 | `P8-AV-BE-02` | Constant sẵn sàng |

### 3.3. Notification Badge (Số đỏ thông báo)

| ID | Task | Status | Priority | Dependency | Definition of Done |
|----|------|--------|----------|------------|-------------------|
| `P8-BADGE-001` | **Bug fix**: Sửa `getUnreadCount()` parse API response (`data as int` thay vì `data as Map`) | `[x]` | P0 | N/A | `unreadCountProvider` trả đúng số |
| `P8-BADGE-002` | Tạo widget `NotificationBadgeIcon` reusable (tách từ code hiện tại trong `HomeScreen`) | `[x]` | P0 | `P8-BADGE-001` | Widget dùng chung, watch `unreadCountProvider`, hiển thị badge đỏ |
| `P8-BADGE-003` | Thay thế code badge trong `HomeScreen` bằng `NotificationBadgeIcon` | `[x]` | P1 | `P8-BADGE-002` | HomeScreen dùng widget chung |
| `P8-BADGE-004` | Thêm `NotificationBadgeIcon` vào AppBar của `ProfileScreen` | `[x]` | P0 | `P8-BADGE-002` | ProfileScreen có badge thông báo |

### 3.4. Notification SignalR & Real-time Deep Link

| ID | Task | Status | Priority | Dependency | Definition of Done |
|----|------|--------|----------|------------|-------------------|
| `P8-NOTI-001` | Tạo `NotificationSignalRService` class mới, kết nối đến `/hubs/notifications` (tách khỏi `SignalRService` hiện tại) | `[x]` | P0 | N/A | `onNotificationReceived` stream nhận `NotificationDto` real-time |
| `P8-NOTI-002` | Tạo `notificationSignalRServiceProvider` (Riverpod singleton) | `[x]` | P0 | `P8-NOTI-001` | Provider sẵn sàng inject |
| `P8-NOTI-003` | Xóa dead code: `onNotificationReceived` stream và handler khỏi `SignalRService` (hiện tại connect sai hub) | `[x]` | P1 | `P8-NOTI-001` | `SignalRService` chỉ còn chat-related code |
| `P8-NOTI-004` | Auto-connect `NotificationSignalRService` trong `AuthNotifier` (sau login/tryAutoLogin) và disconnect (sau logout) | `[x]` | P0 | `P8-NOTI-002` | Notification SignalR tự động connect/disconnect theo auth state |
| `P8-NOTI-005` | Chuyển `MainShell` từ `StatelessWidget` → `ConsumerStatefulWidget`, subscribe `onNotificationReceived` | `[x]` | P0 | `P8-NOTI-001` | Nhận notification real-time → invalidate `unreadCountProvider` |
| `P8-NOTI-006` | Hiển thị `SnackBar` real-time khi có notification mới, tap "Xem" → navigate theo `referenceType` | `[x]` | P0 | `P8-NOTI-005` | SnackBar hiện với title/body, tap điều hướng đúng màn hình |
| `P8-NOTI-007` | Xác minh deep link từ `NotificationsScreen._onTapNotification()` hoạt động đúng | `[x]` | P1 | `P8-NOTI-006` | Tap notification trong list → navigate đến listing/chat/request |

### 3.5. Verify & Tổng Kết

| ID | Task | Status | Priority | Dependency | Definition of Done |
|----|------|--------|----------|------------|-------------------|
| `P8-TEST-001` | Test thủ công login persistence: đăng nhập → kill app → mở lại → tự động vào Home | `[ ]` | P0 | `P8-AUTH-003` | Không cần đăng nhập lại |
| `P8-TEST-002` | Test thủ công avatar upload: chọn ảnh → upload → kiểm tra hiển thị trên Home, Profile, Chat | `[ ]` | P0 | `P8-AV-FE-03` | Avatar đồng bộ mọi màn hình |
| `P8-TEST-003` | Test thủ công notification: nhận notification real-time → badge tăng → tap snackbar → navigate đúng | `[ ]` | P0 | `P8-NOTI-007` | Toàn bộ flow notification hoạt động |
| `P8-TEST-004` | Test edge cases: app background → mở lại → SignalR reconnect; notification khi đang ở sub-screen | `[ ]` | P1 | `P8-TEST-003` | Các edge case hoạt động |
| `P8-TEST-005` | Cập nhật `docs/05-tasks/01-task-board.md` với trạng thái hoàn thành Phase 8 | `[ ]` | P1 | Tất cả P8-* | Task board phản ánh đúng trạng thái |

## 4. Implementation Order

```
Tuần 1: P8-AUTH-* (sửa login) + P8-AV-BE-* (backend avatar) — song song
Tuần 2: P8-AV-FE-* (Flutter avatar) + P8-NOTI-001→003 (SignalR notification hub)
Tuần 3: P8-NOTI-004→007 (auto-connect + snackbar + deep link)
Tuần 4: P8-BADGE-* (badge UI) + P8-TEST-* (verify tổng thể)
```

## 5. Files Modified

### Backend (3 files mới, 2 files sửa)

| File | Action |
|------|--------|
| `UniShare.API/Services/Interfaces/IAvatarService.cs` | **New** |
| `UniShare.API/Services/AvatarService.cs` | **New** |
| `UniShare.API/Controllers/UsersController.cs` | Modify — add `POST me/avatar` |
| `UniShare.API/Extensions/ServiceCollectionExtensions.cs` | Modify — register `IAvatarService` |

### Flutter (3 files mới, 11 files sửa)

| File | Action |
|------|--------|
| `lib/core/network/notification_signalr_client.dart` | **New** |
| `lib/core/network/notification_signalr_provider.dart` | **New** |
| `lib/shared/widgets/notification_badge_icon.dart` | **New** |
| `lib/core/network/token_storage.dart` | Modify — add SharedPreferences fallback |
| `lib/core/network/signalr_client.dart` | Modify — remove notification dead code |
| `lib/core/network/signalr_provider.dart` | Modify — cleanup |
| `lib/core/constants/api_endpoints.dart` | Modify — add `uploadAvatar` |
| `lib/features/auth/data/auth_repository.dart` | Modify — validate token, error callback |
| `lib/features/auth/presentation/providers/auth_provider.dart` | Modify — inject & auto-connect NotificationSignalR |
| `lib/features/auth/presentation/screens/splash_screen.dart` | Modify — fix race condition |
| `lib/features/notifications/data/notifications_api.dart` | Modify — fix parse bug |
| `lib/features/notifications/presentation/screens/notifications_screen.dart` | Modify — nếu cần |
| `lib/features/users/data/user_api.dart` | Modify — add `uploadAvatar` |
| `lib/features/users/data/user_repository.dart` | Modify — add `uploadAvatar` |
| `lib/features/users/presentation/screens/edit_profile_screen.dart` | Modify — add image picker UI |
| `lib/routing/main_shell.dart` | Modify — ConsumerStatefulWidget + SignalR listener + snackbar |
| `lib/features/listings/presentation/screens/home_screen.dart` | Modify — use `NotificationBadgeIcon` |
| `lib/features/users/presentation/screens/profile_screen.dart` | Modify — add `NotificationBadgeIcon` |

## 6. Potential Risks

1. **Samsung Knox/TIMA KeyStore**: `encryptedSharedPreferences: false` đã xử lý. `SharedPreferences` fallback thêm 1 lớp an toàn.
2. **2 WebSocket connections**: Chat + Notification = tốn pin/data hơn. Mitigation: chỉ connect notification hub khi app foreground.
3. **Avatar file cũ**: Chỉ xóa file bắt đầu bằng `/uploads/avatars/`, không xóa external URL (gravatar, etc.).
4. **Token hết hạn khi reconnect SignalR**: Dùng `accessTokenFactory` là closure đọc token mới nhất từ storage mỗi lần reconnect.
5. **Avatar quá lớn**: Frontend resize `maxWidth: 1024, quality: 85`. Backend cũng chặn 5MB.
