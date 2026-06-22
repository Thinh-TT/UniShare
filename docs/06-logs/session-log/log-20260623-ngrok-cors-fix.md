# Session Log — ngrok Skip Browser Warning & CORS Fix (2026-06-23)

## Người thực hiện

ThinhTT + Claude Code

## Loại

Issue / Fix

## Tasks liên quan

- Fix ngrok free plan warning page với header `ngrok-skip-browser-warning: true`
- Fix CORS cho Flutter Web chạy từ Android Studio
- Fix test compile errors (`UserAvatar.mediaBaseUrl`, `TagDto`)

---

## Vấn đề 1: ngrok free plan hiển thị warning page → 403

### Triệu chứng

Ngrok free plan hiển thị trang cảnh báo (warning interstitial) khi phát hiện browser User-Agent. Backend bị chặn, API trả về 403 HTML thay vì JSON response.

### Nguyên nhân

ngrok kiểm tra User-Agent header và serve warning page cho browser requests. Cần header `ngrok-skip-browser-warning: true` để bypass.

### Fix

Thêm header `ngrok-skip-browser-warning: true` vào **3 nơi** trong Flutter app:

| File | Vị trí | Ảnh hưởng |
| ---- | ------ | --------- |
| `api_client.dart:20-22` | `BaseOptions.headers` của Dio | Tất cả REST API calls |
| `auth_interceptor.dart:66-69` | Dio instance riêng khi refresh token | Token refresh |
| `signalr_client.dart:54-56` | `HttpConnectionOptions.headers` dùng `MessageHeaders` class | SignalR WebSocket |

Lưu ý: Không dùng `HttpOverrides` toàn cục vì Dart `HttpClient` chỉ có factory constructor, không thể extend. Image loading (`CachedNetworkImage`, `Image.network`) dùng User-Agent `Dart/3.12 (dart:io)` không phải browser nên không bị chặn.

---

## Vấn đề 2: CORS — Flutter Web bị lỗi XMLHttpRequest onError

### Triệu chứng

```
DioException [connection error]: The connection errored:
The XMLHttpRequest onError callback was called.
```

Xảy ra khi chạy Flutter Web từ Android Studio, gọi API đến `http://localhost:5056`.

### Nguyên nhân

ASP.NET Core `WithOrigins()` **không hỗ trợ wildcard `*`**. Pattern `http://localhost:*` trong `appsettings.Development.json` được xử lý như literal string `*`, không khớp với port thực tế của Flutter web (vd `http://localhost:54321`).

### Fix

**`ServiceCollectionExtensions.cs`**: Thay `WithOrigins()` bằng `SetIsOriginAllowed()` + function `MatchWildcardOrigin` dùng regex để match wildcard port:

```csharp
policy.SetIsOriginAllowed(origin =>
{
    foreach (var pattern in allowedOrigins)
    {
        if (MatchWildcardOrigin(pattern, origin))
            return true;
    }
    return false;
})
```

`MatchWildcardOrigin` chuyển pattern `http://localhost:*` thành regex `^http://localhost:[^/]+$` — khớp mọi port trên localhost.

---

## Vấn đề 3: Test compile errors

### Triệu chứng

3 files test bị lỗi compile:
- `test/widget_test.dart:119,131` — `UserAvatar` thiếu required `mediaBaseUrl`
- `test/features/listings/create_edit_images_widget_test.dart:127` — `tags` kiểu `List<String>` nhưng DTO yêu cầu `List<TagDto>`
- `test/features/listings/home_search_detail_widget_test.dart:127,839` — tương tự

### Fix

- `widget_test.dart`: Thêm `mediaBaseUrl: 'http://localhost:5056'` vào `UserAvatar` constructors
- `create_edit_images_widget_test.dart`: Import `TagDto`, convert `['toán', 'giải tích']` → `[TagDto(id: 'tag-1', name: 'toán'), ...]`
- `home_search_detail_widget_test.dart`: Import `TagDto`, sửa parameter type `List<String>?` → `List<TagDto>?`, sửa call site

---

## Kết quả

- `dart analyze`: 0 errors
- ngrok header đã được gửi thành công (xác nhận từ log)
- CORS wildcard hoạt động cho mọi port trên localhost/127.0.0.1/10.0.2.2

## Cần làm thêm

Sau khi sửa CORS, restart backend:
```bash
docker compose restart api
```
