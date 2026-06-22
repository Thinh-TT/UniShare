# Session Log — Build Fix & Session Check Hang (2026-06-22)

## Người thực hiện

ThinhTT + Claude Code

## Loại

Issue / Decision

## Tasks liên quan

- Build APK cho điện thoại thật
- Debug "Đang kiểm tra phiên..." treo khi khởi động app

---

## Vấn đề 1: Build APK thất bại — Kotlin incremental cache corruption

### Triệu chứng

```
FAILURE: Build failed with an exception.
Execution failed for task ':image_picker_android:compileDebugKotlin'.
> Could not close incremental caches in ... cacheable/caches-jvm/jvm/kotlin
```

### Nguyên nhân

Kotlin 2.3.20 + AGP 9.0.1 trên Windows bị lỗi file locking khi đóng incremental compilation caches của plugin `image_picker_android`. Đây là lỗi race condition giữa Kotlin daemon và Gradle worker threads trên Windows.

### Fix

Thêm vào `android/gradle.properties`:

```properties
kotlin.incremental=false
kotlin.daemon.jvm.options=-Xmx2G -XX:MaxMetaspaceSize=512m
```

Tắt hoàn toàn Kotlin incremental compilation để tránh cache corruption. Trade-off: build chậm hơn nhưng ổn định.

---

## Vấn đề 2: App treo ở màn hình "Đang kiểm tra phiên..."

### Triệu chứng

Mở app trên Samsung Galaxy A56 (SM-A566B) thật → dừng ở màn splash với text "Đang kiểm tra phiên..." quá lâu, không chuyển sang login.

### Nguyên nhân

#### 2a. `10.0.2.2` không hoạt động trên điện thoại thật

`lib/config/app_config.dart` hardcode `apiBaseUrl: 'http://10.0.2.2:5056/api/v1'`. `10.0.2.2` là IP đặc biệt của Android emulator để trỏ tới host `localhost`. Trên điện thoại thật qua Wi-Fi, IP này không tồn tại → API call tới backend treo tới khi timeout (15 giây).

#### 2b. `FlutterSecureStorage` treo trên Samsung

`AndroidOptions(encryptedSharedPreferences: true)` gọi Android KeyStore. Trên Samsung, Knox/TIMA KeyStore có thể treo khi app gọi `read()` lần đầu → `getRefreshToken()` không trả về kịp → splash treo mãi.

#### 2c. Không có timeout ở splash screen

Code gốc gọi `tryAutoLogin()` không có `.timeout()` → nếu auth check treo, UI treo theo.

### Fix

| File                                                        | Thay đổi                                                                                              | Lý do                                                                                             |
| ----------------------------------------------------------- | ----------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------- |
| `lib/config/app_config.dart`                                | Thêm `--dart-define=API_HOST=<IP>` để build với IP LAN thật. Mặc định vẫn là `10.0.2.2` cho emulator. | Cho phép app kết nối backend từ điện thoại thật                                                   |
| `lib/core/network/token_storage.dart`                       | Đổi `encryptedSharedPreferences: true` → `false`, thêm `sharedPreferencesName: 'unishare_prefs'`      | Tránh treo KeyStore trên Samsung. Token vẫn được lưu an toàn trong internal storage riêng của app |
| `lib/features/auth/presentation/screens/splash_screen.dart` | Bọc `tryAutoLogin()` bằng `.timeout(Duration(seconds: 8))`, catch lỗi → redirect `/login`             | Fallback an toàn: nếu auth check quá 8 giây thì cho user vào login luôn                           |

---

## Bài học

1. **Không dùng `10.0.2.2` cho build điện thoại thật.** Luôn dùng `--dart-define` để truyền IP LAN của máy dev. Có thể thêm `local` environment trong `AppConfig` cho rõ ràng hơn.
2. **`encryptedSharedPreferences: true` trên Samsung có vấn đề.** Nên dùng default `FlutterSecureStorage()` hoặc `sharedPreferencesName` thay vì `encryptedSharedPreferences`.
3. **Luôn có timeout cho auth check ở splash.** Tránh user bị kẹt mãi nếu backend không reachable.
4. **Windows Firewall cần mở port backend (5056)** để điện thoại kết nối được qua Wi-Fi.

---

## Lệnh build cho điện thoại thật

```bash
# Lấy IP Wi-Fi của máy dev
ipconfig | grep "IPv4"

# Build với IP đó
flutter build apk --debug --dart-define=API_HOST=192.168.x.x

# Cài qua ADB Wi-Fi
adb -s <device_id> install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## Vấn đề 3: Splash screen vẫn treo sau fix — Storage + GoRouter race condition (2026-06-22)

### Triệu chứng

Mở app trên cả web và Samsung A56 thật → màn hình splash treo ở "Đang kiểm tra phiên..." mãi, không chuyển sang login dù đã có timeout 8 giây.

### Nguyên nhân

#### 3a. `FlutterSecureStorage.read()` treo vô hạn, không throw

`TokenStorage.getRefreshToken()` và `getAccessToken()` gọi `_storage.read()` không có `.timeout()`. Nếu platform backend của `flutter_secure_storage` treo:
- **Web**: IndexedDB/iframe backend không khởi tạo được → Future never completes
- **Samsung**: Android KeyStore (Knox/TIMA) có thể deadlock ngay cả với `encryptedSharedPreferences: false` → Future never completes

Vì Future không complete (không throw), `try-catch` không bắt được → `tryAutoLogin()` treo vĩnh viễn. Fallback timer 8 giây trong splash screen có giải phóng navigation, nhưng `tokenStorage.read()` vẫn treo background.

#### 3b. GoRouter rebuild liên tục mỗi khi auth state thay đổi

`app_router.dart` dùng `ref.watch(authProvider)` trong provider → mỗi lần `tryAutoLogin()` set `state = AuthLoading()` rồi `AuthUnauthenticated()`, GoRouter bị destroy và tạo mới. Khi splash gọi `context.go('/login')` đúng lúc router đang được thay thế → navigation có thể bị nuốt hoặc rơi vào wrong instance.

#### 3c. Timeout chain thiếu đồng bộ

- Dio `connectTimeout`: 15 giây
- Splash fallback timer: 8 giây
- TokenStorage read: **không có timeout**
- Repository `tryAutoLogin()`: **không có timeout tổng**

→ Không có cơ chế nào cắt được storage read treo.

### Fix

| File | Thay đổi | Lý do |
| ---- | -------- | ----- |
| `lib/core/network/token_storage.dart` | Thêm `.timeout(Duration(seconds: 5))` cho `getAccessToken()`, `getRefreshToken()`, `saveTokens()`, `clearTokens()` | Cắt mọi thao tác storage treo sau 5 giây, fail → return null hoặc silent |
| `lib/features/auth/data/auth_repository.dart` | Bọc toàn bộ `tryAutoLogin()` trong `_doTryAutoLogin().timeout(Duration(seconds: 4))` | Bảo vệ kép: storage timeout 5s + repository timeout 4s. Nếu quá 4s → clear tokens, trả null |
| `lib/features/auth/presentation/screens/splash_screen.dart` | Giảm fallback timer 8s → 5s | Người dùng đợi tối đa 5 giây trước khi vào login |
| `lib/routing/app_router.dart` | Đổi `ref.watch` → `ref.read` trong redirect callback | GoRouter tạo **một lần**, không rebuild khi auth state đổi. Tránh race condition navigation |
| `lib/config/app_config.dart` | Thêm `--dart-define=API_HOST=<IP>` dynamic LAN config | Cho phép build với IP LAN bất kỳ, không hardcode `192.168.2.2` |

### Timeout chain mới

```
Splash fallback timer:              5s (hard cutoff, luôn redirect /login)
TokenStorage read/write:            5s (per-operation timeout)
AuthRepository.tryAutoLogin():      4s (tổng timeout cho storage + API)
Dio connectTimeout:                15s (network layer, ít khi chạm tới vì repo đã cắt)
```

### Bài học bổ sung

5. **Luôn có timeout cho mọi I/O operation** — storage, network, file. Không chỉ API call mới cần timeout. Platform channel của Flutter (đặc biệt `flutter_secure_storage`) có thể treo không throw, phá hỏng toàn bộ `try-catch`.
6. **Không dùng `ref.watch` trong GoRouter provider**. GoRouter nên được tạo một lần, dùng `ref.read` trong redirect để đọc state mới nhất mà không rebuild router.
7. **Timeout chain phải có "defense in depth"**: storage timeout < repository timeout < splash fallback timer. Mỗi lớp là một lưới an toàn độc lập.

### Kết quả

App vào thành công trên Samsung A56 qua Wi-Fi. Còn lỗi đăng nhập (sẽ xử lý phiên sau).
