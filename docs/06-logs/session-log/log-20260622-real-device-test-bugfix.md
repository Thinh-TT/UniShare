# Session Log — Real Device Test & Bug Fixes (2026-06-22)

- **Date**: 2026-06-22
- **Performer**: ThinhTT + Claude Code
- **Related Tasks**: Bug fixes (no formal task IDs)
- **Type**: Issue / Fix

## Summary

ThinhTT test app trên Samsung Galaxy A56 thật và Flutter web, phát hiện tổng cộng 15 lỗi qua 7 đợt test ở các luồng: register, login, listings, notifications, filter bottom sheet, create listing, listing detail, chat, images (upload + display). Tất cả đều bắt nguồn từ mismatch giữa backend validation/response và Flutter model/validation, hoặc web platform incompatibility. Đã fix toàn bộ 15 lỗi trên 46 files, Dart analyzer xác nhận 0 errors.

**Đợt 1 (5 lỗi):** Register FullName validation, Login isVerified null, Listings depositAmount null, Notifications 401, Filter overflow.
**Đợt 2 (2 lỗi):** Create Listing thiếu validation rules, Listing Detail tags sai kiểu dữ liệu.
**Đợt 3 (3 lỗi):** Chat Detail 204 String→Map TypeError, Login không navigate, Logout không navigate.
**Đợt 4 (1 lỗi):** ManageImagesScreen GoRouterState trong initState.
**Đợt 5 (1 lỗi):** Create Listing gọi PUT thay vì POST.
**Đợt 6 (1 lỗi):** ManageImagesScreen 405 GET + upload sai response parser.
**Đợt 7 (2 lỗi):** MultipartFile web không hỗ trợ dart:io, ảnh không hiển thị do URL tương đối.

## Bug 1: Register 400 — "Full name must only contain letters and spaces"

### Triệu chứng

```
POST /api/v1/auth/register → 400 Bad Request
{"errors":{"FullName":["Full name must only contain letters and spaces"]}}
```

User nhập `fullName: "thinh1"` (có chữ số).

### Nguyên nhân

Backend `RegisterRequestValidator` yêu cầu regex `^[\p{L}\s]+$` (chỉ Unicode letters + spaces). Flutter `_validateFullName` chỉ kiểm tra độ dài ≥ 2, không kiểm tra ký tự. User không được cảnh báo trước khi gọi API.

### Fix

Thêm regex validation vào `register_screen.dart` `_validateFullName`:

```dart
final nameRegex = RegExp(r'^[\p{L}\s]+$', unicode: true);
if (!nameRegex.hasMatch(trimmed)) {
  return 'Họ tên chỉ được chứa chữ cái và khoảng trắng';
}
```

---

## Bug 2: Login thành công (200) nhưng app báo "Đăng nhập thất bại"

### Triệu chứng

```
POST /api/v1/auth/login → 200 OK
{"data":{"accessToken":"...","refreshToken":"...","user":{...}}}
```

Nhưng Flutter app hiển thị "Đăng nhập thất bại. Vui lòng kiểm tra lại thông tin đăng nhập."

### Nguyên nhân

Backend `UserSummaryDto` (dùng trong `LoginResponse.user`) **không có** field `isVerified`. Chỉ có: `Id`, `Email`, `FullName`, `AvatarUrl`, `ReputationScore`, `TotalReviews`, `SchoolName`, `AreaName`.

Flutter `UserProfileDto` có `final bool isVerified` (non-nullable, required). Generated code:

```dart
isVerified: json['isVerified'] as bool,
```

`json['isVerified']` với key không tồn tại → `null` → `null as bool` throws `TypeError`. Exception bị catch trong `login_screen.dart` → hiển thị generic error message. Token không được lưu.

### Fix

**File: `user_profile_dto.dart`** — thêm `@JsonKey(defaultValue: false)`:

```dart
@JsonKey(defaultValue: false)
final bool isVerified;
```

**File: `user_profile_dto.g.dart`** — sửa generated code:

```dart
isVerified: json['isVerified'] as bool? ?? false,
```

---

## Bug 3: Listings TypeError — `Null is not a subtype of type 'num'`

### Triệu chứng

```
GET /api/v1/listings → 200 OK (16 items)
TypeError: null: type 'Null' is not a subtype of type 'num'
```

App báo "Không thể tải danh sách bài đăng."

### Nguyên nhân

Listing loại **Borrow** có `depositAmount: null` trong API response (borrow không cần đặt cọc). Nhưng:

- `ListingSummaryDto.depositAmount` là `final double depositAmount` (non-nullable)
- `ListingDetailDto.depositAmount` là `final double depositAmount` (non-nullable)

Generated code: `(json['depositAmount'] as num).toDouble()` → `null as num` throws `TypeError`.

Trong khi đó, rental models đã xử lý đúng: `RentalRequestSummaryDto.depositAmount` là `double?` với generated code `(json['depositAmount'] as num?)?.toDouble()`.

### Fix

| File | Thay đổi |
|------|----------|
| `listing_summary_dto.dart` | `final double depositAmount` → `final double? depositAmount`, bỏ `required` |
| `listing_summary_dto.g.dart` | `as num` → `as num?`, thêm `?.` |
| `listing_detail_dto.dart` | Tương tự |
| `listing_detail_dto.g.dart` | Tương tự |
| `listing_detail_screen.dart:330` | `listing.depositAmount > 0` → `listing.depositAmount != null && listing.depositAmount! > 0` |
| `edit_listing_screen.dart:91` | `listing.depositAmount > 0` → `(listing.depositAmount ?? 0) > 0` |
| `listing_form_provider.dart:203` | `listing.depositAmount` → `listing.depositAmount ?? 0` |

---

## Bug 4: Notifications 401 Unauthorized

### Triệu chứng

```
GET /api/v1/me/notifications/unread-count → 401 Unauthorized
```

### Nguyên nhân

Hệ quả trực tiếp của **Bug 2**: login thất bại → token không được lưu vào `TokenStorage` → mọi authenticated request đều 401.

### Fix

Không cần sửa riêng — tự hết khi Bug 2 được fix.

---

## Bug 5: Filter bottom sheet overflow 53px

### Triệu chứng

```
A RenderFlex overflowed by 53 pixels on the bottom.
The relevant error-causing widget was:
  Column file:///.../filter_bottom_sheet.dart:111:14
```

### Nguyên nhân

`AppBottomSheet` bọc child trong `Flexible` (co giãn được nhưng **không scroll**). `FilterBottomSheet` chứa Column với 3 `Wrap` chips (categories 12 items, schools 10 items, areas 8 items) + price inputs → tổng chiều cao vượt viewport. Không có scroll.

Ngoài ra, `AppBottomSheet` đã tự render drag handle (line 33-42), nhưng `FilterBottomSheet` cũng render thêm drag handle riêng (line 115-125) → **trùng lặp**.

### Fix

**File: `filter_bottom_sheet.dart`**
1. Xóa drag handle trùng lặp (cả block `Center > Container`)
2. Bọc `Column` trong `SingleChildScrollView`:

```dart
return Padding(
  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
  child: SingleChildScrollView(        // ← thêm
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header (không còn drag handle trùng)
        Text('Bộ lọc', ...),
        // ... phần còn lại giữ nguyên
      ],
    ),
  ),
);
```

---

## Bài học

1. **Backend DTO và Flutter model phải khớp field-by-field.** Backend `UserSummaryDto` thiếu `isVerified` → Flutter `UserProfileDto` parse fail. Nên có integration test kiểm tra round-trip JSON hoặc dùng code generation từ OpenAPI spec.
2. **Nullable fields từ API phải là nullable trong Flutter model.** `depositAmount` là null cho Borrow listings → Flutter model phải là `double?`, không phải `double`. Dùng pattern `as num?` và `?.toDouble()` như rental models đã làm đúng.
3. **Client-side validation nên mirror server-side validation.** Backend yêu cầu `^[\p{L}\s]+$` cho FullName → Flutter cũng nên validate tương tự để user nhận phản hồi ngay lập tức, không phải đợi API response.
4. **Bottom sheet nội dung dài phải có scroll.** `Flexible` không đủ — cần `SingleChildScrollView` hoặc `ListView`. Và kiểm tra widget cha đã cung cấp drag handle chưa để tránh trùng lặp.
5. **Luôn test trên thiết bị thật.** Các lỗi này không xuất hiện trên emulator vì data test khác (có thể không có Borrow listings với null depositAmount).

## Files Modified

| # | File | Change |
|---|------|--------|
| 1 | `lib/features/auth/presentation/screens/register_screen.dart` | Thêm regex Unicode validation FullName |
| 2 | `lib/features/users/models/user_profile_dto.dart` | Thêm `@JsonKey(defaultValue: false)` cho `isVerified` |
| 3 | `lib/features/users/models/user_profile_dto.g.dart` | `as bool` → `as bool? ?? false` |
| 4 | `lib/features/listings/models/listing_summary_dto.dart` | `depositAmount`: `double` → `double?`, bỏ `required` |
| 5 | `lib/features/listings/models/listing_summary_dto.g.dart` | `as num` → `as num?`, thêm `?.toDouble()` |
| 6 | `lib/features/listings/models/listing_detail_dto.dart` | `depositAmount`: `double` → `double?`, bỏ `required` |
| 7 | `lib/features/listings/models/listing_detail_dto.g.dart` | `as num` → `as num?`, thêm `?.toDouble()` |
| 8 | `lib/features/listings/presentation/screens/listing_detail_screen.dart` | Thêm null-check `depositAmount != null` |
| 9 | `lib/features/listings/presentation/screens/edit_listing_screen.dart` | `depositAmount > 0` → `(depositAmount ?? 0) > 0` |
| 10 | `lib/features/listings/presentation/providers/listing_form_provider.dart` | `listing.depositAmount` → `listing.depositAmount ?? 0` |
| 11 | `lib/features/listings/presentation/widgets/filter_bottom_sheet.dart` | Xóa drag handle trùng + bọc `SingleChildScrollView` |

---

## Bug 6: Create Listing 400 — Title/Description quá ngắn

### Triệu chứng

```
POST /api/v1/listings → 400 Bad Request
{"errors":{"Title":["Title must be at least 5 characters"],
           "Description":["Description must be at least 20 characters"]}}
```

User nhập `title: "test"` (4 ký tự), `description: "tốt"` (3 ký tự).

### Nguyên nhân

Backend `CreateListingRequestValidator` yêu cầu:
- Title: `MinLength(5)`, `MaxLength(200)`
- Description: `MinLength(20)`, `MaxLength(2000)`
- PricePerDay > 0 cho Rent, = 0 cho Borrow
- DepositAmount ≥ 0
- ConditionNote ≤ 500
- Tags ≤ 10, mỗi tag 2-50 ký tự

Frontend `validate()` trong `listing_form_provider.dart` chỉ kiểm tra 3 thứ: title không rỗng, description không rỗng, category được chọn. Tất cả rule còn lại đều thiếu.

### Fix

**File: `listing_form_provider.dart`**
- Thêm 4 error fields mới vào `ListingFormState`: `priceError`, `depositError`, `conditionNoteError`, `tagsError`
- Thêm vào constructor, `copyWith` (cả clear flags)
- Mở rộng `validate()` với đầy đủ rule khớp backend:

| Field | Rule |
|-------|------|
| Title | Không rỗng, min 5, max 200 |
| Description | Không rỗng, min 20, max 2000 |
| PricePerDay | > 0 nếu Rent |
| DepositAmount | ≥ 0 |
| ConditionNote | Max 500 |
| Tags count | Max 10 |
| Each tag | Min 2, max 50 |

- Thêm `clear*Error: true` vào `setPricePerDay`, `setDepositAmount`, `setConditionNote`, `addTag`, `removeTag`

**File: `create_listing_screen.dart`**
- Thêm `Padding > Text` error displays cho `priceError`, `depositError`, `conditionNoteError`, `tagsError` theo pattern của `categoryError`:
```dart
if (formState.priceError != null)
  Padding(
    padding: const EdgeInsets.only(top: 4, left: 4),
    child: Text(formState.priceError!, style: const TextStyle(color: AppColors.danger, fontSize: 12)),
  ),
```

---

## Bug 7: Listing Detail TypeError — `_JsonMap is not a subtype of String`

### Triệu chứng

```
GET /api/v1/listings/{id} → 200 OK
TypeError: Instance of '_JsonMap': type '_JsonMap' is not a subtype of type 'String'
App báo: "Không thể tải thông tin bài đăng."
```

### Nguyên nhân

API trả về tags là array of objects:
```json
"tags": [{"id": "51000000-...", "name": "guitar", "slug": "guitar"}]
```

Nhưng `ListingDetailDto.tags` khai báo `List<String>?`. Generated code:
```dart
tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
```

Mỗi phần tử `e` là `_JsonMap` → `e as String` throws `TypeError`.

`TagDto` (`{id, name, slug}`) đã tồn tại ở `reference/models/tag_dto.dart` — chỉ cần dùng đúng kiểu.

### Fix

| File | Thay đổi |
|------|----------|
| `listing_detail_dto.dart` | `List<String>? tags` → `List<TagDto>? tags`. Thêm import `TagDto`. Khôi phục import `ListingImageDto` (đã bị ghi đè) |
| `listing_detail_dto.g.dart` | `e as String` → `TagDto.fromJson(e as Map<String, dynamic>)` |
| `listing_detail_screen.dart` | `'#$tag'` → `'#${tag.name}'` |
| `listing_form_provider.dart:205` | `listing.tags ?? []` → `(listing.tags ?? []).map((t) => t.name).toList()` |

---

## Bài học (cập nhật)

6. **Client-side validation phải mirror TOÀN BỘ server-side rules, không chỉ required/empty.** Backend có 10+ rule cho create listing → Flutter `validate()` chỉ có 3. User nhập "test" (4 ký tự) cho title → không được cảnh báo → API 400. Mỗi rule thiếu là một round-trip thất bại.
7. **Kiểu dữ liệu của API response cần được kiểm tra thực tế, không giả định.** `List<String>` cho tags hoạt động với mock test data nhưng API thật trả về `List<{id, name, slug}>`. Luôn verify response shape từ API thật hoặc tài liệu API spec. `TagDto` đã có sẵn — chỉ cần dùng đúng chỗ.

## Files Modified (Đợt 2)

| # | File | Change |
|---|------|--------|
| 12 | `lib/features/listings/presentation/providers/listing_form_provider.dart` | Thêm error fields + mở rộng `validate()` với 7 rule mới. Fix tags mapping trong `loadExistingListing` |
| 13 | `lib/features/listings/presentation/screens/create_listing_screen.dart` | Thêm error displays cho price, deposit, conditionNote, tags |
| 14 | `lib/features/listings/models/listing_detail_dto.dart` | `tags`: `List<String>?` → `List<TagDto>?` + import |
| 15 | `lib/features/listings/models/listing_detail_dto.g.dart` | Fix generated cast: `e as String` → `TagDto.fromJson(...)` |
| 16 | `lib/features/listings/presentation/screens/listing_detail_screen.dart` | `'#$tag'` → `'#${tag.name}'` |

---

## Bug 8: Chat Detail TypeError — `type 'String' is not a subtype of type 'Map<String, dynamic>'`

### Triệu chứng

```
GET /conversations/{id} → 200 OK
GET /conversations/{id}/messages → 200 OK (empty items)
PATCH /conversations/{id}/messages/read → 204 No Content (body rỗng)
App báo: "Không thể tải tin nhắn."
TypeError: "": type 'String' is not a subtype of type 'Map<String, dynamic>'
```

### Nguyên nhân

`PATCH /messages/read` trả về **204 No Content** (response body rỗng). Dio set `response.data = ""` (empty String).

`ChatNotifier.loadInitial()` gọi `_repository.markAsRead(conversationId)` → `ConversationsApi.markAsRead()` → `ApiClient.patch<void>()`:

```dart
final response = await _dio.patch(path, data: data);
return ApiResponse.fromJson(response.data, ...);  // response.data = "" → TypeError!
```

`ApiResponse.fromJson("")` gọi `_$ApiResponseFromJson("", callback)`. Tham số `json` được khai báo `Map<String, dynamic>` nhưng nhận `""` (String) → **TypeError**.

Lỗi bị catch trong `loadInitial()` block catch-all (line 111) → set `state = ChatError(...)`, **ghi đè** `ChatLoaded` state đã set thành công trước đó (line 97). Dù `getConversationDetail` và `getMessages` đều thành công (200), người dùng vẫn thấy lỗi "Không thể tải tin nhắn".

Ngoài ra, ngay cả khi `markAsRead` thành công, `_signalR.joinConversation()` cũng có thể throw (nếu hub chưa sẵn sàng) và gây ra cùng một hậu quả.

### Fix

**File: `api_client.dart`** (Fix 1A — Root cause): Guard `patch<T>()` chống response rỗng:

```dart
if (response.data == null || response.data is! Map<String, dynamic>) {
  return ApiResponse<T>(data: null);
}
```

Lợi ích cho tất cả 5 caller dùng `patch<void>()`: `markAsRead` (conversations), `closeListing` (listings), `setCoverImage` (images), `markRead`/`markAllRead` (notifications) — tất cả đều trả 204 và bị crash tương tự.

**File: `chat_provider.dart`** (Fix 1B + 1C — Defense in depth):

- **1B**: Tách `markAsRead()` và `joinConversation()` ra khỏi main try-catch, bọc trong try-catch riêng. Các operation này không critical — không được phép ngăn hiển thị chat.
- **1C**: Bọc toàn bộ body của `_listenForRealTimeMessages()` listener trong try-catch để tránh stream subscription bị kill do lỗi parse hoặc `markAsRead`.

---

## Bug 9: Đăng nhập thành công nhưng không chuyển đến Home

### Triệu chứng

Login API → 200 OK. Token được lưu đúng. Auth state chuyển `AuthAuthenticated`. Nhưng app vẫn ở màn hình Login, không chuyển đến `/home`.

### Nguyên nhân

`LoginScreen._handleLogin()` line 61-66: sau khi `login()` thành công, có comment `// Redirect handled by auth state listener in router` nhưng **không có code navigation nào**.

GoRouter `redirect` callback dùng `ref.read(authProvider)` (one-shot read), không phải `ref.watch`. Redirect chỉ chạy khi có navigation event. Auth state thay đổi nhưng không có navigation event → redirect không bao giờ chạy.

Pattern này từng hoạt động trong `SplashScreen` vì splash **có** explicit navigation (`_navigate('/home')` hoặc `_navigate('/login')`). Login screen và profile screen không làm theo pattern này.

### Fix

**File: `login_screen.dart`** — Thêm navigation sau login thành công:

```dart
await ref.read(authProvider.notifier).login(...);
if (mounted) context.go('/home');
```

---

## Bug 10: Đăng xuất xong vẫn ở trang Profile

### Triệu chứng

Logout API → 200 OK. Token bị xóa. Auth state chuyển `AuthUnauthenticated`. Nhưng app vẫn ở màn hình Profile, không chuyển đến `/login`.

### Nguyên nhân

Giống Bug 9: `ProfileScreen._handleLogout()` gọi `logout()` nhưng không có navigation sau đó. GoRouter redirect không reactive.

### Fix

**File: `profile_screen.dart`** — Thêm navigation sau logout thành công:

```dart
await ref.read(authProvider.notifier).logout();
if (mounted) context.go('/login');
```

---

## Bài học (cập nhật)

8. **HTTP 204 No Content trả về body rỗng.** Dio biểu diễn body rỗng là `""` (String), không phải `null` hay `{}`. `ApiClient` cần guard ở tầng HTTP client, không để từng API tự xử lý. Pattern `response.data is! Map<String, dynamic>` an toàn cho cả 204 lẫn các response không có body.
9. **GoRouter redirect không reactive với Riverpod state changes.** `ref.read()` trong redirect callback là one-shot. Cần explicit navigation (`context.go()`) sau khi state thay đổi từ screen handler, hoặc dùng `ref.watch` + rebuild router (phức tạp hơn). Pattern đơn giản nhất: screen tự navigate sau khi operation thành công.
10. **Non-critical operations không nên nằm trong main try-catch.** `markAsRead` và `joinConversation` là best-effort — thất bại của chúng không nên ngăn hiển thị dữ liệu đã tải thành công. Pattern: tách ra try-catch riêng, swallow error.

## Files Modified (Đợt 3)

| # | File | Change |
|---|------|--------|
| 17 | `lib/core/network/api_client.dart` | Guard `patch<T>()` chống 204 No Content: check `response.data is! Map<String, dynamic>` |
| 18 | `lib/features/conversations/presentation/providers/chat_provider.dart` | Tách `markAsRead` + `joinConversation` khỏi main try-catch. Bọc SignalR listener trong try-catch. |
| 19 | `lib/features/auth/presentation/screens/login_screen.dart` | Thêm `if (mounted) context.go('/home')` sau login |
| 20 | `lib/features/users/presentation/screens/profile_screen.dart` | Thêm `if (mounted) context.go('/login')` sau logout |

---

## Bug 11: ManageImagesScreen crash — `dependOnInheritedWidgetOfExactType` before `initState()` completed

### Triệu chứng

Đăng bài thành công (POST /listings → 201 Created). App navigate sang `ManageImagesScreen` (thêm ảnh). Ngay lập tức crash với assertion:

```
dependOnInheritedWidgetOfExactType<_ModalScopeStatus>() or dependOnInheritedElement()
was called before _ManageImagesScreenState.initState() completed.
```

Stack trace chỉ thẳng:
```
manage_images_screen.dart 27:33  get [_listingId]
manage_images_screen.dart 34:23  initState
```

### Nguyên nhân

`_listingId` là getter gọi `GoRouterState.of(context)`:

```dart
String? get _listingId {
  final state = GoRouterState.of(context);  // ← dùng dependOnInheritedWidgetOfExactType
  return state.extra as String?;
}
```

`initState()` gọi getter này **đồng bộ** (line 34):

```dart
void initState() {
  super.initState();
  final listingId = _listingId;  // ← gọi GoRouterState.of(context) trong initState!
  if (listingId != null) {
    Future.microtask(() { ... });
  }
}
```

Flutter cấm truy cập inherited widgets (`GoRouterState`, `Theme`, `MediaQuery`, v.v.) trong `initState()` vì widget chưa được mount hoàn toàn vào tree. Phải gọi từ `build()`, `didChangeDependencies()`, hoặc trong callbacks bất đồng bộ (microtask, timer).

### Fix

**File: `manage_images_screen.dart`** — Bọc toàn bộ logic khởi tạo (bao gồm `_listingId` getter) vào `Future.microtask()`:

```dart
void initState() {
  super.initState();
  Future.microtask(() {
    final listingId = _listingId;  // OK — initState đã return, context đã sẵn sàng
    if (listingId != null) {
      ref.read(imagesProvider(listingId).notifier).loadImages();
    }
  });
}
```

Lưu ý: `_listingId` getter vẫn có thể được gọi an toàn từ `build()` và các handler khác (vì chúng chạy sau khi widget đã mount).

---

## Bài học (cập nhật)

8. **HTTP 204 No Content trả về body rỗng.** Dio biểu diễn body rỗng là `""` (String), không phải `null` hay `{}`. `ApiClient` cần guard ở tầng HTTP client, không để từng API tự xử lý. Pattern `response.data is! Map<String, dynamic>` an toàn cho cả 204 lẫn các response không có body.
9. **GoRouter redirect không reactive với Riverpod state changes.** `ref.read()` trong redirect callback là one-shot. Cần explicit navigation (`context.go()`) sau khi state thay đổi từ screen handler, hoặc dùng `ref.watch` + rebuild router (phức tạp hơn). Pattern đơn giản nhất: screen tự navigate sau khi operation thành công.
10. **Non-critical operations không nên nằm trong main try-catch.** `markAsRead` và `joinConversation` là best-effort — thất bại của chúng không nên ngăn hiển thị dữ liệu đã tải thành công. Pattern: tách ra try-catch riêng, swallow error.
11. **Không truy cập inherited widgets trong `initState()`.** `GoRouterState.of(context)`, `Theme.of(context)`, `MediaQuery.of(context)` đều dùng `dependOnInheritedWidgetOfExactType`. Flutter cấm gọi chúng trước khi `initState()` hoàn thành. Pattern: hoặc chuyển logic vào `didChangeDependencies()`, hoặc bọc trong `Future.microtask()` / `WidgetsBinding.instance.addPostFrameCallback()`.

## Files Modified (Đợt 4)

| # | File | Change |
|---|------|--------|
| 21 | `lib/features/images/presentation/screens/manage_images_screen.dart` | Bọc `_listingId` getter + `loadImages()` vào `Future.microtask()` trong `initState()` để tránh truy cập inherited widget quá sớm |

---

## Bug 12: Create Listing gọi PUT thay vì POST → 404 Not Found

### Triệu chứng

Điền form tạo bài đăng mới, nhấn "Tiếp theo - Thêm ảnh":

```
PUT /api/v1/listings/{id} → 404 Not Found
{"type":"...","title":"Not Found","status":404,"detail":"Listing not found"}
```

App báo: "Không thể lưu bài đăng. DioException [bad response]: ... status code of 404 ..."

Listing ID trong URL PUT (`0b94ee91-...`) là ID của bài đăng đã tạo từ **lần trước**. Data gửi đi là data của bài đăng **mới**. Rõ ràng app đang cố UPDATE một listing không tồn tại thay vì CREATE mới.

### Nguyên nhân

`CreateListingScreen` và `EditListingScreen` **dùng chung** `listingFormProvider` — một `StateNotifierProvider` singleton trong Riverpod container. State của provider tồn tại xuyên suốt vòng đời app.

`ListingFormNotifier.submit()` phân nhánh dựa trên `isEditMode`:

```dart
if (state.isEditMode && state.listingId != null) {
  // PUT update
  final result = await _repository.updateListing(state.listingId!, request);
} else {
  // POST create
  final result = await _repository.createListing(request);
}
```

Khi user từng mở `EditListingScreen` để sửa bài đăng, `loadExistingListing()` set `isEditMode: true` và `listingId: <id>`. Khi quay lại `CreateListingScreen`, **không có code nào reset form về create mode**. Provider vẫn giữ `isEditMode: true` và `listingId` cũ → `submit()` gọi PUT thay vì POST → 404 vì listing ID đó không tồn tại hoặc không thuộc về user.

Đây là classic bug của shared mutable state giữa 2 màn hình có intent khác nhau.

### Fix

**File: `create_listing_screen.dart`** — Reset form về create mode trong `initState()`:

```dart
@override
void initState() {
  super.initState();
  // Reset form to create mode — the shared listingFormProvider may
  // still be in edit mode from a previous EditListingScreen visit.
  ref.read(listingFormProvider.notifier).reset();
  _titleController.clear();
  _descriptionController.clear();
  _priceController.clear();
  _depositController.clear();
  _conditionController.clear();
  _tagController.clear();
}
```

`reset()` set toàn bộ state về `const ListingFormState()` (tất cả field rỗng, `isEditMode: false`, `listingId: null`). Các TextEditingController cũng được clear để đồng bộ với form state.

---

## Bài học (cập nhật)

8. **HTTP 204 No Content trả về body rỗng.** Dio biểu diễn body rỗng là `""` (String), không phải `null` hay `{}`. `ApiClient` cần guard ở tầng HTTP client, không để từng API tự xử lý. Pattern `response.data is! Map<String, dynamic>` an toàn cho cả 204 lẫn các response không có body.
9. **GoRouter redirect không reactive với Riverpod state changes.** `ref.read()` trong redirect callback là one-shot. Cần explicit navigation (`context.go()`) sau khi state thay đổi từ screen handler, hoặc dùng `ref.watch` + rebuild router (phức tạp hơn). Pattern đơn giản nhất: screen tự navigate sau khi operation thành công.
10. **Non-critical operations không nên nằm trong main try-catch.** `markAsRead` và `joinConversation` là best-effort — thất bại của chúng không nên ngăn hiển thị dữ liệu đã tải thành công. Pattern: tách ra try-catch riêng, swallow error.
11. **Không truy cập inherited widgets trong `initState()`.** `GoRouterState.of(context)`, `Theme.of(context)`, `MediaQuery.of(context)` đều dùng `dependOnInheritedWidgetOfExactType`. Flutter cấm gọi chúng trước khi `initState()` hoàn thành. Pattern: hoặc chuyển logic vào `didChangeDependencies()`, hoặc bọc trong `Future.microtask()` / `WidgetsBinding.instance.addPostFrameCallback()`.
12. **Shared StateNotifierProvider giữa các màn hình khác intent là antipattern.** `CreateListingScreen` (POST) và `EditListingScreen` (PUT) dùng chung `listingFormProvider`. Khi không có reset ở screen entry, state từ màn hình trước "rò rỉ" sang màn hình sau. Pattern: hoặc dùng provider riêng cho từng màn hình, hoặc reset state trong `initState()`.

## Files Modified (Đợt 5)

| # | File | Change |
|---|------|--------|
| 22 | `lib/features/listings/presentation/screens/create_listing_screen.dart` | Thêm `initState()` reset form + clear controllers để đảm bảo luôn ở create mode |

---

## Bug 13: ManageImagesScreen 405 Method Not Allowed + upload không hoạt động

### Triệu chứng

Mở màn hình ảnh bài đăng (sau khi tạo listing thành công):

```
GET /listings/{id}/images → 405 Method Not Allowed (content-length: 0)
```

App báo: "Không thể tải ảnh. DioException [bad response]: ... status code of 405 ..."

Nút "Thêm ảnh" vẫn hiển thị nhưng khi chọn ảnh và upload thì không nhận và không hiển thị được.

### Nguyên nhân

**Backend không có `GET /listings/{id}/images`.** Controller chỉ có:
- `POST /listings/{id}/images` — upload
- `PATCH /listings/{id}/images/{imageId}/cover` — set cover
- `PUT /listings/{id}/images/order` — reorder
- `DELETE /listings/{id}/images/{imageId}` — delete

Ảnh được trả về trong `ListingDetailDto.images` (field `images: List<ListingImageDto>?`) khi gọi `GET /listings/{id}`.

Lỗi thứ hai (upload không hoạt động): `uploadImages()` gọi `postMultipart<Map<String, dynamic>>()`. Backend trả về `ApiResponse<List<ListingImageDto>>` — `{"data": [...images...], "message": "..."}`. `data` field là **List**, không phải Map. Callback trong `postMultipart` cast `json as Map<String, dynamic>` → **TypeError** (chưa báo vì GET 405 xảy ra trước).

### Fix

**File: `api_client.dart`** — Thêm `postMultipartRaw()` method (pattern giống `postRaw`, `getRaw`...) để trả về raw JSON Map thay vì dùng callback cast Map:

```dart
Future<Map<String, dynamic>> postMultipartRaw({
  required String path,
  required FormData formData,
}) async {
  final response = await _dio.post(
    path,
    data: formData,
    options: Options(contentType: 'multipart/form-data'),
  );
  return response.data as Map<String, dynamic>;
}
```

**File: `images_api.dart`** — Viết lại `getImages()` và `uploadImages()`:

- `getImages()`: Gọi `getRaw(ApiEndpoints.listingById(listingId))` thay vì GET `/images`, extract `images` từ listing detail response.
- `uploadImages()`: Dùng `postMultipartRaw()` thay vì `postMultipart<Map>()`, parse `response['data']` thành `List<dynamic>` rồi map qua `ListingImageDto.fromJson`.

---

## Bài học (cập nhật)

8. **HTTP 204 No Content trả về body rỗng.** Dio biểu diễn body rỗng là `""` (String), không phải `null` hay `{}`. `ApiClient` cần guard ở tầng HTTP client, không để từng API tự xử lý. Pattern `response.data is! Map<String, dynamic>` an toàn cho cả 204 lẫn các response không có body.
9. **GoRouter redirect không reactive với Riverpod state changes.** `ref.read()` trong redirect callback là one-shot. Cần explicit navigation (`context.go()`) sau khi state thay đổi từ screen handler, hoặc dùng `ref.watch` + rebuild router (phức tạp hơn). Pattern đơn giản nhất: screen tự navigate sau khi operation thành công.
10. **Non-critical operations không nên nằm trong main try-catch.** `markAsRead` và `joinConversation` là best-effort — thất bại của chúng không nên ngăn hiển thị dữ liệu đã tải thành công. Pattern: tách ra try-catch riêng, swallow error.
11. **Không truy cập inherited widgets trong `initState()`.** `GoRouterState.of(context)`, `Theme.of(context)`, `MediaQuery.of(context)` đều dùng `dependOnInheritedWidgetOfExactType`. Flutter cấm gọi chúng trước khi `initState()` hoàn thành. Pattern: hoặc chuyển logic vào `didChangeDependencies()`, hoặc bọc trong `Future.microtask()` / `WidgetsBinding.instance.addPostFrameCallback()`.
12. **Shared StateNotifierProvider giữa các màn hình khác intent là antipattern.** `CreateListingScreen` (POST) và `EditListingScreen` (PUT) dùng chung `listingFormProvider`. Khi không có reset ở screen entry, state từ màn hình trước "rò rỉ" sang màn hình sau. Pattern: hoặc dùng provider riêng cho từng màn hình, hoặc reset state trong `initState()`.
13. **Backend response shape quyết định Flutter parsing approach.** `ApiResponse<List<T>>` có `data` là JSON array → không thể dùng `postMultipart<Map>()` vì callback cast `as Map`. Cần method riêng (`postMultipartRaw`) để parse thủ công. Tương tự, không phải mọi resource đều có GET endpoint riêng — đôi khi phải lấy từ resource cha (listing detail chứa images).

## Files Modified (Đợt 6)

| # | File | Change |
|---|------|--------|
| 23 | `lib/core/network/api_client.dart` | Thêm `postMultipartRaw()` — multipart upload trả về raw JSON Map |
| 24 | `lib/features/images/data/images_api.dart` | Viết lại `getImages()` dùng listing detail endpoint. Viết lại `uploadImages()` dùng `postMultipartRaw()` và parse List response đúng |

---

## Bug 14: Upload ảnh lỗi trên Web — MultipartFile không hỗ trợ dart:io

### Triệu chứng

Khi chạy Flutter web app (`flutter run -d chrome`), chọn ảnh và upload:

```
DartError: Unsupported operation: MultipartFile is only supported where dart:io is available.
dart-sdk/lib/_internal/js_dev_runtime/private/ddc_runtime/errors.dart 274:3  throw_
package:dio_web_adapter/src/multipart_file_impl.dart 13:5                multipartFileFromPath
package:dio/src/multipart_file.dart 139:12                               fromFile
package:unishare/features/images/data/images_api.dart 46:31              <fn>
```

App crash ngay khi gọi `uploadImages()`.

### Nguyên nhân

Toàn bộ chain upload ảnh sử dụng `dart:io.File` — class không tồn tại trên web platform:

- `manage_images_screen.dart:52`: `File(x.path)` — `dart:io.File` constructor
- `images_provider.dart:70`: `uploadImages(List<File> files)` — tham số `dart:io.File`
- `images_api.dart:46`: `MultipartFile.fromFile(file.path)` — Dio web adapter không thể mở file từ path trên web

`MultipartFile.fromFile()` gọi xuống `dart:io.File` để đọc file. Trên web, Dio web adapter (`dio_web_adapter`) throw `Unsupported operation`.

Mặc dù `image_picker` package hỗ trợ web (trả về `XFile`), nhưng code Flutter lại ép sang `dart:io.File` — vô hiệu hóa web support.

### Fix

Chuyển toàn bộ chain sang dùng `MultipartFile.fromBytes()` — API hoạt động trên cả web và mobile:

**File: `images_api.dart`**
- Bỏ `import 'dart:io';`, thêm `import 'dart:typed_data';`
- `uploadImages(String listingId, List<File> files)` → `uploadImages(String listingId, List<({Uint8List bytes, String filename})> files)`
- `MultipartFile.fromFile(file.path)` → `MultipartFile.fromBytes(file.bytes, filename: file.filename)`

**File: `images_provider.dart`**
- Bỏ `import 'dart:io';`, thêm `import 'dart:typed_data';`
- `uploadImages(List<File> files)` → `uploadImages(List<({Uint8List bytes, String filename})> files)`

**File: `manage_images_screen.dart`**
- Bỏ `import 'dart:io';`, thêm `import 'dart:typed_data';`
- `File(x.path)` → Đọc bytes từ `XFile`: `await x.readAsBytes()` + `x.name` cho filename

---

## Bug 15: Ảnh không hiển thị — URL tương đối không được resolve

### Triệu chứng

Sau khi upload ảnh thành công (POST trả về 201), ảnh được lưu vào database với `imageUrl` đúng. Nhưng trong Flutter app:

- **Manage Images screen**: Grid hiển thị icon `broken_image` thay vì ảnh thật
- **Listing Detail screen**: Carousel hiển thị placeholder xám
- **Listing Card**: Cover image hiển thị `image_not_supported`
- **User Avatar**: Một số avatar không hiển thị

### Nguyên nhân

Backend trả về image URL là **server-relative path** (không có scheme + host):

```json
"imageUrl": "/uploads/listings/abc-123/photo.jpg"
"coverImageUrl": "/uploads/listings/abc-123/cover.jpg"
"avatarUrl": "/uploads/avatars/user-1/avatar.jpg"
```

Đây là pattern chuẩn của ASP.NET — lưu path tương đối, server phục vụ static files qua `app.UseStaticFiles()`.

Nhưng Flutter app truyền trực tiếp các path này vào `CachedNetworkImage(imageUrl: ...)` và `Image.network(...)`. Trên web, `/uploads/...` được resolve relative đến **origin của Flutter web app** (VD: `http://localhost:PORT/`) thay vì **API server** (`http://localhost:5056/`). Kết quả: 404 Not Found.

Trên mobile, path không có scheme → `CachedNetworkImage` không biết gửi request đến đâu → hiển thị error widget.

### Fix

Tạo cơ chế resolve URL: ghép server origin (từ `apiBaseUrl` bỏ `/api/v1`) vào trước path tương đối. Giữ nguyên URL đã absolute (http/https).

**File: `app_config.dart`** — Thêm `mediaBaseUrl` getter:
```dart
/// Base URL for media files. Strips /api/v1 from apiBaseUrl.
/// e.g. "http://localhost:5056/api/v1" → "http://localhost:5056"
String get mediaBaseUrl => apiBaseUrl.replaceAll('/api/v1', '');
```

**File: `lib/shared/utils/image_url_resolver.dart`** (NEW) — Utility function:
```dart
String resolveImageUrl(String mediaBaseUrl, String? imageUrl) {
  if (imageUrl == null || imageUrl.isEmpty) return '';
  if (imageUrl.startsWith('http://') || imageUrl.startsWith('https://')) {
    return imageUrl; // Already absolute
  }
  return '$mediaBaseUrl$imageUrl';
}
```

**Tất cả vị trí hiển thị ảnh** — áp dụng `resolveImageUrl(mediaBaseUrl, imageUrl)`:

| File | Widget | Trước | Sau |
|------|--------|-------|-----|
| `manage_images_screen.dart` | `_ImageTile` | `image.imageUrl` | `resolveImageUrl(mediaBaseUrl, image.imageUrl)` |
| `listing_card.dart` | `ListingCard` | `listing.coverImageUrl!` | `resolveImageUrl(mediaBaseUrl, listing.coverImageUrl)` |
| `listing_detail_screen.dart` | Carousel | `listing.images![index].imageUrl` | `resolveImageUrl(mediaBaseUrl, ...)` |
| `user_avatar.dart` | `UserAvatar` | `avatarUrl!` | `resolveImageUrl(mediaBaseUrl, avatarUrl)` |
| `rental_request_detail_screen.dart` | Thumbnail | `request.listingImageUrl!` | `resolveImageUrl(mediaBaseUrl, ...)` |
| `my_requests_screen.dart` | Thumbnail | `request.listingImageUrl!` | `resolveImageUrl(mediaBaseUrl, ...)` |

- `ListingCard` và `UserAvatar` là `StatelessWidget` → thêm `required String mediaBaseUrl` parameter
- Các màn hình là `ConsumerWidget`/`ConsumerStatefulWidget` → đọc `mediaBaseUrl` từ `ref.read(appConfigProvider).mediaBaseUrl` trong helper methods
- Tất cả 9 file gọi `ListingCard(...)` và 11 file gọi `UserAvatar(...)` được cập nhật để truyền `mediaBaseUrl`

### Ghi chú

- `resolveImageUrl()` an toàn với URL đã absolute — nếu backend sau này trả về full URL, code vẫn hoạt động
- `mediaBaseUrl` được derive từ `apiBaseUrl` nên tự động đúng với mọi môi trường (dev, staging, LAN, ngrok)
- Đây là Flutter-side fix. Backend fix (trả về absolute URL) sẽ là improvement trong tương lai, giúp mọi client (mobile, web, third-party) đều được lợi

---

## Bài học (cập nhật)

8. **HTTP 204 No Content trả về body rỗng.** Dio biểu diễn body rỗng là `""` (String), không phải `null` hay `{}`. `ApiClient` cần guard ở tầng HTTP client, không để từng API tự xử lý. Pattern `response.data is! Map<String, dynamic>` an toàn cho cả 204 lẫn các response không có body.
9. **GoRouter redirect không reactive với Riverpod state changes.** `ref.read()` trong redirect callback là one-shot. Cần explicit navigation (`context.go()`) sau khi state thay đổi từ screen handler, hoặc dùng `ref.watch` + rebuild router (phức tạp hơn). Pattern đơn giản nhất: screen tự navigate sau khi operation thành công.
10. **Non-critical operations không nên nằm trong main try-catch.** `markAsRead` và `joinConversation` là best-effort — thất bại của chúng không nên ngăn hiển thị dữ liệu đã tải thành công. Pattern: tách ra try-catch riêng, swallow error.
11. **Không truy cập inherited widgets trong `initState()`.** `GoRouterState.of(context)`, `Theme.of(context)`, `MediaQuery.of(context)` đều dùng `dependOnInheritedWidgetOfExactType`. Flutter cấm gọi chúng trước khi `initState()` hoàn thành. Pattern: hoặc chuyển logic vào `didChangeDependencies()`, hoặc bọc trong `Future.microtask()` / `WidgetsBinding.instance.addPostFrameCallback()`.
12. **Shared StateNotifierProvider giữa các màn hình khác intent là antipattern.** `CreateListingScreen` (POST) và `EditListingScreen` (PUT) dùng chung `listingFormProvider`. Khi không có reset ở screen entry, state từ màn hình trước "rò rỉ" sang màn hình sau. Pattern: hoặc dùng provider riêng cho từng màn hình, hoặc reset state trong `initState()`.
13. **Backend response shape quyết định Flutter parsing approach.** `ApiResponse<List<T>>` có `data` là JSON array → không thể dùng `postMultipart<Map>()` vì callback cast `as Map`. Cần method riêng (`postMultipartRaw`) để parse thủ công. Tương tự, không phải mọi resource đều có GET endpoint riêng — đôi khi phải lấy từ resource cha (listing detail chứa images).
14. **`dart:io` không khả dụng trên web — dùng API cross-platform.** `MultipartFile.fromFile()`, `File()`, và mọi class trong `dart:io` không tồn tại trên Flutter web. Dùng `MultipartFile.fromBytes()` + `Uint8List` thay thế — hoạt động trên cả web, Android, iOS. `image_picker` trả về `XFile` với `.readAsBytes()` cross-platform.
15. **Backend trả về relative path cho static files — client phải resolve thành absolute URL.** ASP.NET pattern: lưu `/uploads/...` trong DB, serve qua `UseStaticFiles()`. Flutter app cần ghép server origin trước khi hiển thị qua `CachedNetworkImage`/`Image.network`. Tạo utility `resolveImageUrl()` tập trung để xử lý một lần, áp dụng khắp nơi. Ưu tiên Flutter-side fix trước (nhanh, an toàn), backend-side fix sau (toàn diện hơn).

## Files Modified (Đợt 7)

| # | File | Change |
|---|------|--------|
| 25 | `lib/features/images/data/images_api.dart` | `MultipartFile.fromFile()` → `fromBytes()`. `List<File>` → record `({Uint8List bytes, String filename})` |
| 26 | `lib/features/images/presentation/providers/images_provider.dart` | `List<File>` → `List<({Uint8List bytes, String filename})>`. Bỏ `import 'dart:io'` |
| 27 | `lib/features/images/presentation/screens/manage_images_screen.dart` | Đọc bytes từ `XFile.readAsBytes()` thay `File(x.path)`. Thêm resolve URL cho `_ImageTile` |
| 28 | `lib/config/app_config.dart` | Thêm `mediaBaseUrl` getter — bỏ `/api/v1` suffix từ `apiBaseUrl` |
| 29 | `lib/shared/utils/image_url_resolver.dart` | **NEW** — `resolveImageUrl(mediaBaseUrl, imageUrl)` utility |
| 30 | `lib/shared/widgets/listing_card.dart` | Thêm `mediaBaseUrl` param. Resolve `coverImageUrl` qua `resolveImageUrl()` |
| 31 | `lib/shared/widgets/user_avatar.dart` | Thêm `mediaBaseUrl` param. Resolve `avatarUrl` qua `resolveImageUrl()` |
| 32 | `lib/features/listings/presentation/screens/listing_detail_screen.dart` | Resolve image URL trong carousel |
| 33 | `lib/features/rentals/presentation/screens/rental_request_detail_screen.dart` | Resolve `listingImageUrl` |
| 34 | `lib/features/rentals/presentation/screens/my_requests_screen.dart` | Resolve `listingImageUrl` |
| 35 | `lib/features/listings/presentation/screens/home_screen.dart` | Truyền `mediaBaseUrl` vào `ListingCard` |
| 36 | `lib/features/listings/presentation/screens/search_screen.dart` | Truyền `mediaBaseUrl` vào `ListingCard` |
| 37 | `lib/features/listings/presentation/screens/my_listings_screen.dart` | Truyền `mediaBaseUrl` vào `ListingCard` |
| 38 | `lib/features/users/presentation/screens/profile_screen.dart` | Truyền `mediaBaseUrl` vào `UserAvatar` |
| 39 | `lib/features/users/presentation/screens/edit_profile_screen.dart` | Truyền `mediaBaseUrl` vào `UserAvatar` |
| 40 | `lib/features/reviews/presentation/screens/review_form_screen.dart` | Truyền `mediaBaseUrl` vào `UserAvatar` |
| 41 | `lib/features/comments/presentation/screens/comments_screen.dart` | Truyền `mediaBaseUrl` vào `UserAvatar` |
| 42 | `lib/features/conversations/presentation/screens/chat_detail_screen.dart` | Truyền `mediaBaseUrl` vào `UserAvatar` |
| 43 | `lib/features/conversations/presentation/screens/conversation_list_screen.dart` | Truyền `mediaBaseUrl` vào `UserAvatar` |
| 44 | `test/features/auth/auth_screens_widget_test.dart` | Thêm `appConfigProvider` override |
| 45 | `test/features/listings/home_search_detail_widget_test.dart` | Thêm `appConfigProvider` override vào tất cả `ProviderScope` |
| 46 | `test/features/listings/create_edit_images_widget_test.dart` | Thêm `appConfigProvider` override vào tất cả `ProviderScope` |
