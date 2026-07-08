# Session Log - Phase 5: Auth & Profile UI Screens

**Date:** 2026-06-22
**Branch:** main
**Status:** DONE

## Summary

Triển khai 4 tasks P0 của Phase 5 - Flutter UI Screens: Auth & Profile. Tất cả 4 tasks đã hoàn thành với 0 errors, 0 warnings từ `dart analyze`, và 11/11 tests pass.

## Tasks Completed

### FE-AUTH-001: Splash/Onboarding ✅
- **File:** `lib/features/auth/presentation/screens/splash_screen.dart` (polish)
- Thêm onboarding message cho AuthInitial: "Chào mừng bạn đến với UniShare! Đăng nhập để bắt đầu chia sẻ đồ dùng sinh viên."
- Xóa unreachable code (CircularProgressIndicator fallback)
- Giữ UI hiện tại: logo xanh 80x80, "UniShare" heading, tagline, LoadingState

### FE-AUTH-002: Login Screen ✅
- **File:** `lib/features/auth/presentation/screens/login_screen.dart` (polish)
- Validation cải thiện: email regex nếu chứa `@`, phone ≥6 ký tự nếu không; password ≥6
- Error parsing từ AppException thay vì hardcoded message
- Form disabled (AbsorbPointer) khi loading để chống double-submit
- UI polish: divider "hoặc" giữa nút Login và links, cải thiện spacing

### FE-AUTH-003: Register Screen ✅
- **File:** `lib/features/auth/presentation/screens/register_screen.dart` (polish)
- Thêm confirm password field + validator
- Validation: fullName ≥2, email regex, phone format Việt Nam (0xxxxxxxxx), password ≥6
- Error parsing từ AppException
- Success: AlertDialog "Đăng ký thành công!" thay vì SnackBar
- Form disabled (AbsorbPointer) khi loading

### FE-PROF-001: Profile + Edit Profile ✅
- **Files:**
  - `lib/features/users/presentation/screens/profile_screen.dart` (full rewrite)
  - `lib/features/users/presentation/screens/edit_profile_screen.dart` (full rewrite)
  - `lib/features/users/data/user_api.dart` (NEW)
  - `lib/features/users/data/user_repository.dart` (NEW)
  - `lib/features/users/presentation/providers/user_provider.dart` (NEW)
  - `lib/features/reference/data/reference_api.dart` (NEW)
  - `lib/features/reference/presentation/providers/reference_provider.dart` (NEW)
- Profile: Avatar, name, email, verified badge, school/area, stats (reputation + reviews), menu (edit profile, my listings, my requests), logout với ConfirmDialog
- Edit Profile: form pre-filled từ API, email disabled, phone validation, school/area pickers qua AppBottomSheet, save → PUT /users/me → invalidate userProfileProvider
- States: Loading, Error (với retry), Data
- Pull-to-refresh trên profile

## Infrastructure Added

| File | Purpose |
|---|---|
| `lib/core/network/api_client.dart` | Thêm `putRaw()` method |
| `lib/shared/widgets/app_input.dart` | Thêm `textInputAction`, `onFieldSubmitted` |
| `lib/features/reference/data/reference_api.dart` | API calls: GET /schools, GET /areas |
| `lib/features/reference/presentation/providers/reference_provider.dart` | FutureProvider cho schools, areas |
| `lib/features/users/data/user_api.dart` | API calls: GET /users/me, PUT /users/me |
| `lib/features/users/data/user_repository.dart` | Repository wrapper cho user operations |
| `lib/features/users/presentation/providers/user_provider.dart` | FutureProvider cho userProfile |

## Provider Architecture

```
apiClientProvider (existing)
  ├── referenceApiProvider (NEW) → schoolsProvider, areasProvider (FutureProvider)
  └── userApiProvider (NEW) → userRepositoryProvider (NEW) → userProfileProvider (FutureProvider)
```

## Verification Results

- `dart analyze`: **0 errors, 0 warnings** (23 infos - pre-existing style hints from Phase 4)
- `flutter test`: **11/11 tests pass**
- File count: 11 files changed (6 new, 5 modified), ~1,200 lines new code

## Key Decisions

1. **FutureProvider over StateNotifierProvider** cho profile và reference data: read-only data không cần mutable state, AsyncValue.when() map trực tiếp sang Loading/Error/Data UI
2. **UserApi riêng biệt** thay vì thêm vào AuthApi: separation of concerns, AuthApi đã có getMyProfile() nhưng UserApi là nơi đúng cho các user operations
3. **AppBottomSheet cho school/area pickers**: tận dụng widget có sẵn, UI nhất quán
4. **Không dùng Future.delayed trong SplashScreen**: gây lỗi "pending timer" trong test framework (FakeAsync)
5. **Thêm textInputAction/onFieldSubmitted vào AppInput**: cần thiết cho form UX (keyboard next/done actions)

## Patterns Used

- ConsumerStatefulWidget + ref.watch/ref.read/ref.listen
- FutureProvider.when(loading/error/data) → LoadingState/ErrorState/content
- Shared widgets: AppButton, AppInput, UserAvatar, ConfirmDialog, AppBottomSheet, StatusBadge
- Form validation với GlobalKey<FormState> + validator functions
- AbsorbPointer để chống double-submit
- ref.invalidate() để force refresh dữ liệu
- Tất cả string UI tiếng Việt
