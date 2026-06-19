# Color Guidelines

## 1. Mục tiêu tài liệu

- Quy định hệ màu dùng cho giao diện mobile UniShare.
- Đảm bảo UI nhất quán giữa các màn hình trong `/docs/04-ui/01-ui-sitemap-and-wireframe.md`.
- Làm cơ sở để triển khai theme trong Flutter.

## 2. Định hướng màu sắc

UniShare sử dụng phong cách sạch, sáng và thân thiện với sinh viên.

- **Màu chủ đạo**: trắng, dùng cho nền chính và bề mặt nội dung.
- **Màu phụ**: xanh lá, dùng cho hành động chính, điểm nhấn và trạng thái tích cực.
- **Màu trung tính**: xám, dùng cho chữ phụ, border, divider và nền phụ.
- **Màu cảnh báo/lỗi**: dùng tiết chế cho trạng thái nghiệp vụ như lỗi form, yêu cầu bị từ chối hoặc giao dịch cần chú ý.

Nguyên tắc chung:

- Không dùng quá nhiều sắc xanh lá trên cùng một màn hình.
- Ưu tiên nền trắng, khoảng trắng rõ ràng và card có border nhẹ.
- Nút hành động chính dùng xanh lá để người dùng dễ nhận ra thao tác quan trọng.
- Các trạng thái thành công có thể dùng xanh lá nhưng không cạnh tranh với CTA chính.

## 3. Bảng màu chính

| Token | Màu | Hex | Mục đích sử dụng |
| --- | --- | --- | --- |
| `primary.white` | Trắng | `#FFFFFF` | Nền chính của app, card, input |
| `primary.green` | Xanh lá chính | `#16A34A` | CTA chính, icon active, badge tích cực |
| `primary.greenDark` | Xanh lá đậm | `#15803D` | Trạng thái pressed/hover, nhấn mạnh |
| `primary.greenLight` | Xanh lá nhạt | `#DCFCE7` | Background badge, chip selected, success surface |
| `neutral.50` | Xám rất nhạt | `#F9FAFB` | Nền phụ, section background |
| `neutral.100` | Xám nhạt | `#F3F4F6` | Divider nhẹ, disabled background |
| `neutral.200` | Border | `#E5E7EB` | Border input, card, separator |
| `neutral.500` | Xám chữ phụ | `#6B7280` | Text phụ, placeholder, metadata |
| `neutral.700` | Xám chữ chính phụ | `#374151` | Body text |
| `neutral.900` | Gần đen | `#111827` | Heading, title, text quan trọng |

## 4. Màu trạng thái

| Token | Màu | Hex | Mục đích sử dụng |
| --- | --- | --- | --- |
| `success` | Xanh thành công | `#16A34A` | Giao dịch hoàn tất, đặt cọc đã thanh toán, đánh giá tốt |
| `warning` | Vàng cảnh báo | `#F59E0B` | Yêu cầu đang chờ, cần xác nhận |
| `danger` | Đỏ lỗi | `#DC2626` | Lỗi form, xóa bài, từ chối yêu cầu |
| `info` | Xanh thông tin | `#2563EB` | Link, thông tin phụ, trạng thái hệ thống |
| `disabled` | Xám disabled | `#D1D5DB` | Button/input không khả dụng |

## 5. Quy tắc sử dụng màu theo UI

### 5.1. Nền và bề mặt

- App background mặc định: `neutral.50`.
- Card, modal, bottom sheet, input background: `primary.white`.
- Border card/input: `neutral.200`.
- Divider: `neutral.100` hoặc `neutral.200`.

### 5.2. Text

- Heading, title, tên bài đăng: `neutral.900`.
- Body text: `neutral.700`.
- Metadata như thời gian, khu vực, số lượt upvote: `neutral.500`.
- Link text: `primary.green` hoặc `info` nếu là link hệ thống.
- Text trên button xanh lá: `primary.white`.

### 5.3. Button

| Loại button | Background | Text/Icon | Border |
| --- | --- | --- | --- |
| Primary | `primary.green` | `primary.white` | Không cần |
| Primary pressed | `primary.greenDark` | `primary.white` | Không cần |
| Secondary | `primary.white` | `primary.green` | `primary.green` |
| Ghost | Transparent | `neutral.700` hoặc `primary.green` | Không cần |
| Danger | `danger` | `primary.white` | Không cần |
| Disabled | `disabled` | `neutral.500` | Không cần |

Ví dụ sử dụng:

- `Gửi yêu cầu thuê/mượn`: Primary.
- `Lưu thay đổi`: Primary.
- `Chat`: Secondary.
- `Xóa bài đăng`: Danger.
- `Hủy`: Ghost.

### 5.4. Bottom navigation

- Background: `primary.white`.
- Icon/text inactive: `neutral.500`.
- Icon/text active: `primary.green`.
- Top border hoặc shadow nhẹ: `neutral.200`.

### 5.5. Chip, tag và filter

- Chip mặc định: background `primary.white`, border `neutral.200`, text `neutral.700`.
- Chip selected: background `primary.greenLight`, border `primary.green`, text `primary.greenDark`.
- Tag trong bài đăng nên dùng `primary.greenLight` để gợi cảm giác nhẹ và thân thiện.

### 5.6. Listing card

- Background: `primary.white`.
- Border: `neutral.200`.
- Title: `neutral.900`.
- Giá thuê: `primary.green`.
- Khu vực/trường/thời gian: `neutral.500`.
- Badge `Available`: background `primary.greenLight`, text `primary.greenDark`.
- Badge `Reserved` hoặc `Pending`: background vàng nhạt, text `warning`.
- Badge `Closed`, `Rejected`, `Cancelled`: background đỏ nhạt, text `danger`.

### 5.7. Form và validation

- Input background: `primary.white`.
- Input border mặc định: `neutral.200`.
- Input focused: `primary.green`.
- Placeholder: `neutral.500`.
- Error text và border lỗi: `danger`.
- Success helper text nếu cần: `success`.

### 5.8. Notification

- Thông báo chưa đọc: background `primary.greenLight` hoặc có chấm `primary.green`.
- Thông báo đã đọc: background `primary.white`.
- Icon notification theo type:
  - Upvote/comment/message: `primary.green`.
  - Request pending: `warning`.
  - Rejected/cancelled/error: `danger`.

## 6. Gợi ý theme Flutter

```dart
class AppColors {
  static const white = Color(0xFFFFFFFF);

  static const green = Color(0xFF16A34A);
  static const greenDark = Color(0xFF15803D);
  static const greenLight = Color(0xFFDCFCE7);

  static const neutral50 = Color(0xFFF9FAFB);
  static const neutral100 = Color(0xFFF3F4F6);
  static const neutral200 = Color(0xFFE5E7EB);
  static const neutral500 = Color(0xFF6B7280);
  static const neutral700 = Color(0xFF374151);
  static const neutral900 = Color(0xFF111827);

  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const info = Color(0xFF2563EB);
  static const disabled = Color(0xFFD1D5DB);
}
```

Gợi ý mapping:

```dart
final theme = ThemeData(
  scaffoldBackgroundColor: AppColors.neutral50,
  primaryColor: AppColors.green,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.green,
    primary: AppColors.green,
    surface: AppColors.white,
    error: AppColors.danger,
  ),
);
```

## 7. Accessibility và contrast

- Text chính trên nền trắng dùng `neutral.900` hoặc `neutral.700`, không dùng xám quá nhạt.
- Text trên button xanh lá phải dùng trắng.
- Không dùng màu sắc là tín hiệu duy nhất; trạng thái lỗi/cảnh báo cần có text hoặc icon đi kèm.
- Button disabled phải khác rõ button active về cả màu nền và màu chữ.
- Với thông tin quan trọng như trạng thái yêu cầu, nên kết hợp badge màu + nhãn chữ.

## 8. Checklist kiểm tra màu sắc

- Màn hình chính giữ nền sáng, không bị phủ quá nhiều màu xanh.
- CTA chính nổi bật bằng `primary.green`.
- Các card/listing/input có border nhẹ và đủ khoảng trắng.
- Trạng thái lỗi dùng `danger`, không dùng xanh lá.
- Trạng thái đang chờ dùng `warning`.
- Bottom navigation có active state rõ ràng.
- Text có độ tương phản đủ đọc trên nền trắng.
