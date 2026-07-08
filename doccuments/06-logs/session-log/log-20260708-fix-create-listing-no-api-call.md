# Session Log — Fix Create Listing không gọi API (2026-07-08)

- **Date**: 2026-07-08
- **Performer**: ThinhTT + Claude Code
- **Related Tasks**: Bug fix (no formal task ID)
- **Type**: Issue / Fix

## Summary

Khi nhấn nút "Tiếp theo - Thêm ảnh" trên màn hình `CreateListingScreen`, không có API nào được gọi. Theo mong đợi, phải gọi `POST /api/v1/listings` để tạo bài đăng, sau đó chuyển đến màn hình `ManageImagesScreen` để quản lý ảnh.

## Triệu chứng

- User điền đầy đủ thông tin form tạo bài đăng
- Nhấn "Tiếp theo - Thêm ảnh"
- Không có HTTP request nào được gửi đi
- App không chuyển màn hình, không báo lỗi rõ ràng

## Nguyên nhân

### Root Cause 1: Title & Description validation errors không hiển thị

`create_listing_screen.dart` sử dụng `validator` (Form-level validation) cho 2 field title và description:

```dart
AppInput(
  label: 'Tiêu đề *',
  validator: (_) => formState.titleError,  // ← Form-level validator
),
```

Nhưng `_formKey.currentState!.validate()` **không bao giờ được gọi** trong code. `ListingFormNotifier.validate()` tự chạy logic validation riêng và set error vào state, nhưng `TextFormField` chỉ hiển thị lỗi từ `validator` khi `Form.validate()` được gọi hoặc `autovalidateMode` được bật.

**Hậu quả**: Nếu user nhập title < 5 ký tự hoặc description < 20 ký tự:
1. `validate()` → fail → return `null` (không gọi API)
2. `formState.titleError` / `formState.descriptionError` được set
3. Nhưng `TextFormField` không hiển thị lỗi vì `Form.validate()` chưa được gọi
4. User không thấy thông báo lỗi nào → tưởng nút bị hỏng

Ngược lại, category, price, deposit, conditionNote, tags hiển thị lỗi qua `Text` widget trực tiếp nên luôn visible.

### Root Cause 2: Dead code `if (!_initialized)` không bao giờ chạy

```dart
void _initListeners() {
  if (_initialized) return;
  _initialized = true;  // ← gán _initialized = true
  // ... add listeners
}

// Trong build():
_initListeners();  // ← _initialized = true sau dòng này

if (!_initialized) {  // ← LUÔN LUÔN false → dead code
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _titleController.text = formState.title;  // sync state → controllers
    ...
  });
}
```

`_initListeners()` gán `_initialized = true` trước khi check `if (!_initialized)`, khiến khối sync controllers từ form state không bao giờ thực thi. Điều này ảnh hưởng đến **Edit mode**: khi load dữ liệu bài đăng cũ, controllers không được đồng bộ từ state → text field hiển thị trống.

### Contributing Factor: EditListingScreen thiếu error displays

`edit_listing_screen.dart` cũng dùng `validator` cho title/description (cùng vấn đề) và **thiếu hoàn toàn** error display cho price, deposit, conditionNote, tags (chỉ có category error được hiển thị).

## Fix

### Fix 1: Dùng `errorText` thay vì `validator` cho title & description

**File: `create_listing_screen.dart`**

```dart
// Before:
AppInput(
  label: 'Tiêu đề *',
  validator: (_) => formState.titleError,  // ← chỉ hiển thị khi Form.validate()
),

// After:
AppInput(
  label: 'Tiêu đề *',
  errorText: formState.titleError,  // ← hiển thị trực tiếp, luôn visible
),
```

Áp dụng tương tự cho description field và cả 2 field trong `edit_listing_screen.dart`.

### Fix 2: Tách flag `_controllersSynced` khỏi `_initialized`

**File: `create_listing_screen.dart`**

```dart
bool _controllersSynced = false;

void _syncControllersFromState(ListingFormState formState) {
  if (_controllersSynced) return;
  _controllersSynced = true;
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _titleController.text = formState.title;
    _descriptionController.text = formState.description;
    _priceController.text = formState.pricePerDay > 0
        ? formState.pricePerDay.toStringAsFixed(0) : '';
    _depositController.text = formState.depositAmount > 0
        ? formState.depositAmount.toStringAsFixed(0) : '';
    _conditionController.text = formState.conditionNote;
  });
}

// Trong build():
_syncControllersFromState(formState);  // ← chỉ chạy 1 lần, sau khi listeners đã được thêm
```

### Fix 3: Thêm error displays cho EditListingScreen

Thêm `Padding > Text` error displays cho price, deposit, conditionNote, tags trong `edit_listing_screen.dart` (theo pattern có sẵn trong `create_listing_screen.dart`).

## Files Modified

| # | File | Change |
|---|------|--------|
| 1 | `lib/features/listings/presentation/screens/create_listing_screen.dart` | Fix `_initialized` dead code → tách `_controllersSynced`. Thêm `_syncControllersFromState()`. Thay `validator` → `errorText` cho title & description |
| 2 | `lib/features/listings/presentation/screens/edit_listing_screen.dart` | Thay `validator` → `errorText` cho title & description. Thêm error displays cho price, deposit, conditionNote, tags |

## Verification

- Dart analyzer: **0 errors**
- Widget tests: **17/17 pass** (`create_edit_images_widget_test.dart`)

## Bài học

1. **Không dùng `validator` (Form-level validation) nếu không gọi `Form.validate()`.** Khi có custom validation logic ngoài Form (như trong `ListingFormNotifier.validate()`), phải dùng `errorText` để hiển thị lỗi trực tiếp. `validator` chỉ hoạt động khi `_formKey.currentState!.validate()` được gọi.

2. **Tránh đặt flag quá sớm trước khi logic hoàn tất.** Pattern "gán flag → check flag" chỉ hoạt động khi flag được gán SAU logic cần guard. Trong trường hợp này, `_initialized = true` được gán trong `_initListeners()` nhưng logic sync controllers cần check `!_initialized` — dẫn đến dead code.

3. **Shared StateNotifierProvider cần sync 2 chiều cẩn thận.** `listingFormProvider` được dùng chung giữa Create và Edit mode. Controllers → state (listeners) và state → controllers (sync) đều phải hoạt động. Khi sync state → controllers bị dead code, Edit mode hiển thị form trống dù state đã có dữ liệu.
