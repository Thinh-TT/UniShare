# Session Log: Phase 8 - Login Persistence Fixes (P8-AUTH-001 → P8-AUTH-004)

- **Ngày**: 2026-06-30
- **Người thực hiện**: ThinhTT + Claude Code
- **Loại**: Fix / Improvement
- **Task liên quan**: P8-AUTH-001, P8-AUTH-002, P8-AUTH-003, P8-AUTH-004

## 1. Vấn Đề

App không giữ phiên đăng nhập sau khi đóng (kill app → mở lại → phải login lại). Có 3 bug chính:

1. **`TokenStorage` single point of failure**: Chỉ dùng `FlutterSecureStorage` mà không có fallback. Trên Samsung Knox, secure storage treo/timeout → mất token.
2. **Race condition `SplashScreen`**: Dùng `didChangeDependencies` + `_hasChecked` flag để fire auth check. `didChangeDependencies` có thể gọi nhiều lần khi `InheritedWidget` rebuild — flag ngăn double-fire nhưng pattern không chuẩn.
3. **Không validate token sau refresh**: `tryAutoLogin()` nhận được user từ API nhưng access token rỗng (do storage fail) vẫn set `AuthAuthenticated`.

## 2. Giải Pháp

### P8-AUTH-001: SharedPreferences Fallback

**File**: `lib/core/network/token_storage.dart`

Thêm `shared_preferences: ^2.3.4` vào pubspec.yaml. `TokenStorage` giờ:

- **Save**: Ghi vào cả `FlutterSecureStorage` + `SharedPreferences` (prefix `sp_`)
- **Read**: Ưu tiên secure storage. Nếu null/exception → fallback sang SharedPreferences. Nếu có token ở SP → migrate ngược về secure storage.
- **Clear**: Xóa cả 2 storage.

**Why**: FlutterSecureStorage dùng platform keychain/keystore — trên Samsung Knox/TIMA có thể treo hoặc throw. SharedPreferences không bảo mật bằng nhưng luôn available, đảm bảo token không mất.

### P8-AUTH-002: Fix Race Condition SplashScreen

**File**: `lib/features/auth/presentation/screens/splash_screen.dart`

Thay `didChangeDependencies` + `_hasChecked` → `initState` + `addPostFrameCallback`.

**Why**: `initState` chạy đúng 1 lần trong lifecycle widget, không phụ thuộc InheritedWidget. `_hasChecked` flag không còn cần thiết. Giữ `_hasNavigated` guard và `mounted` check để an toàn.

### P8-AUTH-003: Validate Token Sau Refresh

**File**: `lib/features/auth/presentation/providers/auth_provider.dart`

Sau khi `_authRepository.tryAutoLogin()` trả user, đọc accessToken/refreshToken. Nếu rỗng → gọi `logout()` + set `AuthUnauthenticated` thay vì `AuthAuthenticated`.

**Why**: Nếu storage fail giữa lúc refresh và lúc đọc token, state sẽ có user nhưng token rỗng → mọi API call sau đó đều 401.

### P8-AUTH-004: Debug Logging

**File**: `lib/features/auth/presentation/providers/auth_provider.dart`

Thêm `debugPrint(...)` ở mỗi bước trong `tryAutoLogin()`: start, success (kèm userId), no session, token validation fail, error với stack trace.

**Why**: Debug trên thiết bị thật cần log để biết chính xác bước nào fail (storage hay network).

## 3. Files Changed

| File | Action | Status |
|------|--------|--------|
| `pubspec.yaml` | Modify — add `shared_preferences` | ✅ |
| `lib/core/network/token_storage.dart` | Rewrite — add SharedPreferences fallback | ✅ |
| `lib/features/auth/presentation/screens/splash_screen.dart` | Modify — fix race condition | ✅ |
| `lib/features/auth/presentation/providers/auth_provider.dart` | Modify — token validation + debug log | ✅ |
| `docs/05-tasks/01-task-board.md` | Update status → `[x]` | ✅ |

## 4. Verification

| Step | Result |
|------|--------|
| `dart pub get` | ✅ Passed (7 new dependencies) |
| `dart run build_runner build` | ✅ Passed (74 outputs) |
| `dart analyze` | ✅ 0 errors (warnings pre-existing) |
| `flutter test` (auth) | ✅ 62/62 pass |
| `flutter test` (all) | ✅ 254 tests, 17 failures pre-existing in `rental_deposit_review_widget_test.dart` |

## 5. Bài Học

1. **Storage fallback pattern**: Luôn có 2 lớp storage cho token — secure (chính) + plain text (fallback). Samsung Knox/TIMA là vấn đề thực tế trên thiết bị Việt Nam.
2. **`initState` vs `didChangeDependencies`**: `initState` là nơi đúng để fire 1 lần. `didChangeDependencies` phù hợp cho việc subscribe InheritedWidget changes, không phải initialization.
3. **Defensive programming**: Luôn validate post-condition — API trả user không đồng nghĩa token còn valid.
