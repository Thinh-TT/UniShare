# Session Log — Build Release APK (2026-06-23)

## Người thực hiện

ThinhTT + Claude Code

## Loại

Decision / Task

## Tasks liên quan

- `BUILD-001`: Cấu hình Android app id, app name, icon
- `BUILD-002`: Cấu hình permission Android
- `BUILD-003`: Cấu hình signing key cho release
- `BUILD-005`: Build release APK

---

## Kết quả

✅ **Build release APK thành công**

| Mục | Giá trị |
|---|---|
| **File APK** | `UniShare.APP\build\app\outputs\flutter-apk\app-release.apk` |
| **Kích thước** | 54.2 MB |
| **Ngrok domain** | `overhung-cannon-mystify.ngrok-free.dev` |
| **API status** | HTTP 200 (đã verify) |
| **Signing key** | `android/upload-keystore.jks` (alias: `upload`) |

---

## Chi tiết cấu hình

### BUILD-001: App ID, name, icon

- **App ID**: `com.unishare.unishare` — đã có sẵn trong `build.gradle.kts`
- **App name**: Đã sửa `android:label` trong `AndroidManifest.xml` từ `"unishare"` → `"UniShare"`
- **App icon**: File `ic_launcher.png` đã có ở tất cả mipmap densities (mdpi → xxxhdpi). Chưa thay icon custom — đang dùng icon Flutter mặc định

### BUILD-002: Permissions

- `INTERNET` permission: ✅ đã có sẵn
- `networkSecurityConfig`: ✅ đã có `@xml/network_security_config` để cho phép cleartext traffic (cần cho dev)
- Camera/Gallery: Chưa thêm `CAMERA` và `READ_EXTERNAL_STORAGE` permission. App vẫn upload ảnh qua `image_picker` plugin — plugin này tự thêm permission qua manifest merger. Nếu cần chụp ảnh trực tiếp, sẽ phải khai báo thêm `CAMERA`.

### BUILD-003: Signing key

- **Keystore**: `android/upload-keystore.jks` (2728 bytes, tạo 2026-06-23)
- **Key properties**: `android/key.properties` cấu hình đầy đủ `storePassword`, `keyPassword`, `keyAlias`, `storeFile`
- **build.gradle.kts**: Đã cấu hình `signingConfigs.release` load từ `key.properties`, `buildTypes.release` dùng signing config đó

### BUILD-005: Lệnh build

```bash
# Build release APK với ngrok domain động
flutter build apk --release --dart-define=NGROK_DOMAIN=overhung-cannon-mystify.ngrok-free.dev
```

Build mất ~76 giây trên máy dev.

---

## Cấu hình AppConfig

File `lib/config/app_config.dart` hỗ trợ 3 cách chọn backend URL:

1. **`--dart-define=NGROK_DOMAIN=<domain>`** — Ưu tiên cao nhất. Tạo ngrok config với HTTPS
2. **`--dart-define=API_HOST=<IP>`** — LAN config với HTTP
3. **`--dart-define=ENV=dev|staging|lan|ngrok`** — Fallback static config

App release này dùng cách 1 với `NGROK_DOMAIN=overhung-cannon-mystify.ngrok-free.dev`.

---

## Lưu ý

1. **Ngrok free plan** — URL thay đổi mỗi lần restart Docker. Quy trình build lần sau:
   ```bash
   docker compose up -d                      # Start Docker
   docker logs unishare-ngrok | grep "url="  # Lấy URL mới
   cd UniShare.APP
   flutter build apk --release --dart-define=NGROK_DOMAIN=<url-moi>
   ```

2. **App icon** hiện là Flutter mặc định (hình vuông xanh). Cần thay icon UniShare custom — có thể dùng `flutter_launcher_icons` package hoặc thay thủ công các file `ic_launcher.png` trong `mipmap-*/`.

3. **Android 14+ package visibility** — `AndroidManifest.xml` đã có `<queries>` block nhưng chỉ cho `ACTION_PROCESS_TEXT`. Có thể cần thêm nếu dùng intent mở app khác (gọi điện, maps, etc.).

4. **Chưa có `CAMERA` permission** — `image_picker` plugin tự thêm qua manifest merger ở build time, không cần khai báo thủ công trừ khi cần camera trực tiếp.

---

## Tasks còn lại (Phase 7)

| ID | Task | Status |
|---|---|---|
| `BUILD-006` | Smoke test APK release trên thiết bị thật | `[ ]` |
| `BUILD-007` | Chuẩn bị release notes và danh sách known issues | `[ ]` |
