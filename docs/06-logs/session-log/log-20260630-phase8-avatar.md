# Session Log: Phase 8 - Upload Avatar (P8-AV-BE-01 → P8-AV-FE-04)

- **Ngày**: 2026-06-30
- **Người thực hiện**: ThinhTT + Claude Code
- **Loại**: Feature / New
- **Task liên quan**: P8-AV-BE-01, P8-AV-BE-02, P8-AV-BE-03, P8-AV-FE-01, P8-AV-FE-02, P8-AV-FE-03, P8-AV-FE-04

## 1. Mô Tả

Triển khai tính năng upload avatar cho người dùng: cho phép chọn/chụp ảnh đại diện từ điện thoại, upload lên server, hiển thị đồng bộ trên mọi màn hình.

## 2. Kiến Trúc

### Backend (ASP.NET Core)

```
POST /api/v1/users/me/avatar
Content-Type: multipart/form-data
Body: file (IFormFile)

Response: { data: { avatarUrl: "/uploads/avatars/<guid>.jpg" } }
```

Service layer gồm:
- **`IAvatarService`** — interface với 1 method `UploadAvatarAsync(Guid userId, IFormFile file)`
- **`AvatarService`** — validate file (.jpg/.png/.webp, ≤5MB), lưu xuống `wwwroot/uploads/avatars/`, xóa file cũ nếu là local upload, cập nhật `User.AvatarUrl` trong DB
- **`UsersController.UploadAvatar`** — endpoint HTTP, parse `ClaimTypes.NameIdentifier`, gọi service, trả `ApiResponse<AvatarUploadResponse>`

### Flutter (Riverpod)

- **`ApiEndpoints.uploadAvatar`** — constant `/users/me/avatar`
- **`UserApi.uploadAvatar(String filePath)`** — tạo `FormData` với `MultipartFile`, gọi `postMultipartRaw`
- **`UserRepository.uploadAvatar(String filePath)`** — delegate đến `UserApi`
- **`EditProfileScreen._pickAndUploadAvatar()`** — `showModalBottomSheet` chọn camera/gallery → `ImagePicker.pickImage(maxWidth: 1024, quality: 85)` → upload → `ref.invalidate(userProfileProvider)` → SnackBar

Đồng bộ avatar: sau upload, `userProfileProvider` bị invalidate → tất cả widget đang watch provider này (UserAvatar trên Home, Profile, Comments, Chat) tự động rebuild với URL mới.

## 3. Files Changed

| File | Action |
|------|--------|
| `UniShare.API/Services/Interfaces/IAvatarService.cs` | **New** |
| `UniShare.API/Services/AvatarService.cs` | **New** |
| `UniShare.API/Models/DTOs/Users/AvatarUploadResponse.cs` | **New** |
| `UniShare.API/Controllers/UsersController.cs` | Modify — add `UploadAvatar` endpoint |
| `UniShare.API/Extensions/ServiceCollectionExtensions.cs` | Modify — register `IAvatarService` |
| `lib/core/constants/api_endpoints.dart` | Modify — add `uploadAvatar` |
| `lib/features/users/data/user_api.dart` | Modify — add `uploadAvatar()` |
| `lib/features/users/data/user_repository.dart` | Modify — add `uploadAvatar()` |
| `lib/features/users/presentation/screens/edit_profile_screen.dart` | Modify — add image picker + camera overlay |
| `test/features/auth/auth_screens_widget_test.dart` | Modify — fix test assertion for changed text |

## 4. Verification

| Step | Result |
|------|--------|
| `dotnet build` (backend) | ✅ 0 errors |
| `dart pub get` | ✅ Passed |
| `dart analyze` | ✅ 0 errors (no new warnings) |
| `flutter test` (auth) | ✅ 22/22 pass |
| `flutter test` (all) | ✅ 254 tests pass, 17 failures pre-existing (unchanged) |

## 5. Chi Tiết Kỹ Thuật

### Backend Validation
- **Định dạng**: `.jpg`, `.jpeg`, `.png`, `.webp` (case-insensitive)
- **Kích thước tối đa**: 5 MB
- **Xóa file cũ**: Chỉ xóa file bắt đầu bằng `/uploads/avatars/` (local upload), không xóa external URL (Gravatar, Google avatar, v.v.)
- **Response**: `ApiResponse<AvatarUploadResponse>` với `avatarUrl` là server-relative path

### Flutter Image Picker
- Nguồn: Camera hoặc Gallery (chọn qua BottomSheet)
- Resize: `maxWidth: 1024, maxHeight: 1024, imageQuality: 85`
- UI overlay: Camera icon ở góc dưới-phải avatar, loading overlay khi đang upload
- Upload xong → xóa file tạm → invalidate `userProfileProvider` → SnackBar thành công

### Sync Pattern
`userProfileProvider` là `FutureProvider` được watch bởi `UserAvatar` widget. Khi `ref.invalidate(userProfileProvider)` được gọi, provider tự động re-fetch từ API → tất cả widget rebuild với avatar URL mới.
