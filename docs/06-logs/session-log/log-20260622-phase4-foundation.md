# Session Log - Phase 4 Flutter Foundation

**Ngày**: 2026-06-22
**Người thực hiện**: ThinhTT + Claude (AI Agent)
**Task liên quan**: Phase 4 - `FE-CORE-001` đến `FE-CORE-006`
**Loại**: Implementation

---

## Tóm tắt

Triển khai toàn bộ Phase 4 - Flutter Foundation cho dự án UniShare. Đây là bước đặt nền móng Flutter để Phase 5+ xây dựng màn hình UI chi tiết.

## Kết quả đạt được

### ✅ Step A: Platform Configs
- Thêm `INTERNET` permission vào `android/app/src/main/AndroidManifest.xml` (trước đó chỉ có ở debug/profile)
- Thêm `NSAppTransportSecurity` + `NSAllowsArbitraryLoads` vào `ios/Runner/Info.plist` cho dev HTTP connections
- **File**: 2 sửa

### ✅ Step A2: Packages
- Thêm vào `pubspec.yaml`:
  - Runtime: `flutter_riverpod`, `dio`, `go_router`, `flutter_secure_storage`, `json_annotation`, `signalr_netcore`, `intl`, `cached_network_image`, `image_picker`
  - Dev: `json_serializable`, `build_runner`, `mocktail`
- **File**: 1 sửa

### ✅ Step B: FE-CORE-004 — Models/DTOs (~38 files)
- 5 enum classes: `ListingType`, `ListingStatus`, `RentalRequestStatus`, `DepositStatus`, `NotificationType`
- Response wrappers: `ApiResponse<T>`, `PagedResponse<T>`, `ProblemDetails`
- Auth models: `LoginRequest`, `RegisterRequest`, `RefreshTokenRequest`, `LoginResponse`
- User models: `UserSummaryDto`, `UserProfileDto`, `UserPublicProfileDto`, `UpdateProfileRequest`
- Listing models: `ListingSummaryDto`, `ListingDetailDto`, `CreateListingRequest`, `UpdateListingRequest`
- Image models: `ListingImageDto`, `ImageOrderItem`, `ImageOrderRequest`
- Reference models: `CategoryDto`, `TagDto`, `SchoolDto`, `AreaDto`
- Comment models: `CommentDto`, `CreateCommentRequest`, `UpdateCommentRequest`
- Conversation models: `ConversationDto`, `MessageDto`, `SendMessageRequest`
- Rental models: `RentalRequestDto`, `CreateRentalRequestRequest`
- Deposit models: `DepositDto`, `MarkPaidRequest`
- Review models: `ReviewDto`, `CreateReviewRequest`
- Notification models: `NotificationDto`, `UnreadCountDto`
- `ApiEndpoints` constants class
- Tất cả dùng `@JsonSerializable()`, cần `build_runner` để generate `.g.dart`

### ✅ Step C: FE-CORE-001 — Theme Configuration (2 files)
- `lib/config/app_colors.dart`: 14 static color constants theo color guidelines
- `lib/config/app_theme.dart`: `ThemeData.lightTheme` với đầy đủ textTheme, button themes, bottomNav, chip, input, card, appBar, dialog, snackbar, FAB

### ✅ Step D: FE-CORE-003 — API Client (7 files)
- `core/network/token_storage.dart`: flutter_secure_storage wrapper
- `core/errors/app_exception.dart`: AppException hierarchy
- `core/network/auth_interceptor.dart`: Dio interceptor — JWT attach + 401 refresh (Completer pattern chống race)
- `core/network/api_client.dart`: Dio singleton với get/getPaged/post/put/patch/delete/postMultipart
- `core/network/signalr_client.dart`: SignalR hub connection
- `core/constants/api_endpoints.dart`: tất cả endpoint path constants
- `core/network/api_response.dart`: generic response wrappers

### ✅ Step E: FE-CORE-005 — Shared Components (11 widgets)
- `AppButton`: Primary/Secondary/Ghost/Danger variants + loading + disabled
- `AppInput`: TextFormField với label, validation, states
- `ListingCard`: Card hiển thị listing summary với CachedNetworkImage
- `StatusBadge`: Badge màu theo trạng thái (success/warning/danger/info/neutral)
- `LoadingState`: Centered spinner
- `EmptyState`: Icon + title + subtitle + optional action
- `ErrorState`: Error icon + message + retry button
- `ConfirmDialog`: AlertDialog với confirm/cancel, isDangerous mode
- `UserAvatar`: CircleAvatar với network image hoặc initials fallback + reputation badge
- `AppBottomSheet`: Styled modal bottom sheet wrapper
- `AppChip`: FilterChip default/selected states

### ✅ Step F: FE-CORE-002 — Routing/Navigation (25 files)
- `routing/route_names.dart`: Route path constants
- `routing/main_shell.dart`: Scaffold + 5-tab BottomNavigationBar
- `routing/app_router.dart`: GoRouter với ShellRoute, auth redirect, deep link
- 22 stub screens (mỗi screen là placeholder tối thiểu cho Phase 5)

### ✅ Step G: FE-CORE-006 — Auth Guard (8 files)
- `auth_state.dart`: Sealed class hierarchy (Initial/Loading/Authenticated/Unauthenticated)
- `auth_api.dart`: Gọi auth endpoints
- `auth_repository.dart`: Orchestration login/register/tryAutoLogin/logout
- `auth_provider.dart`: Riverpod providers (tokenStorage, apiClient, authApi, authRepository, authNotifier)
- `splash_screen.dart`: Kiểm tra phiên → redirect
- `login_screen.dart`: Form đăng nhập tối thiểu
- `register_screen.dart`: Form đăng ký tối thiểu
- `login_required_modal.dart`: Bottom sheet mời đăng nhập

### ✅ Step H: Wire Everything (3 files)
- `lib/main.dart`: Rewrite với ProviderScope + AppConfig override
- `lib/app.dart`: ConsumerWidget + MaterialApp.router + GoRouter + AppTheme
- `lib/config/app_config.dart`: Thêm `appConfigProvider`

---

## Decisions Made

1. **Riverpod thay vì Bloc/Provider**: Compile-safe, không cần BuildContext, AsyncValue built-in. Đủ mạnh cho quy mô dự án này.
2. **GoRouter thay vì Navigator 2.0**: ShellRoute cho bottom nav, redirect auth guard, deep link support cho notifications.
3. **Dio thay vì http package**: Interceptor cho JWT + 401 refresh, multipart upload, logging.
4. **json_serializable thay vì freezed**: Đơn giản hơn cho Phase 4, có thể nâng cấp lên freezed sau nếu cần immutable state phức tạp.
5. **flutter_secure_storage thay vì shared_preferences**: Bảo mật cho JWT tokens.
6. **signalr_netcore**: Tương thích với ASP.NET Core SignalR backend.

---

## ⚠️ Step I: Cần làm Session Sau

Các bước cần chạy để hoàn tất Phase 4:

1. **`flutter pub get`** - Cài đặt tất cả packages (có thể bị chậm do network)
2. **`dart run build_runner build --delete-conflicting-outputs`** - Generate `.g.dart` files cho tất cả model classes
3. **`flutter analyze`** - Kiểm tra lỗi compile, import thiếu
4. **`flutter test`** - Chạy test suite
5. Sửa lỗi nếu có từ analyze/test
6. **`flutter run`** - Kiểm tra app chạy trên emulator (splash → login → home với bottom nav)

### Lưu ý khi chạy build_runner:
- Cần chạy từ thư mục `E:\UniShare\UniShare.APP`
- Flag `--delete-conflicting-outputs` để xóa các file `.g.dart` cũ nếu có conflict
- Nếu build_runner quá chậm, có thể thêm flag `--build-filter` để chỉ build từng phần

---

## File Count Summary

| Loại | Số lượng |
|------|----------|
| Files mới tạo | ~92 |
| Files sửa | 4 |
| Tổng code (ước tính) | ~4,000-5,000 dòng |
