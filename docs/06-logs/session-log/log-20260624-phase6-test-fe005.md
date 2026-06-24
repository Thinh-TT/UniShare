# Session Log — TEST-FE-005: Widget Test Comments/Chat

| Field       | Value                              |
| ----------- | ---------------------------------- |
| **Ngày**    | 2026-06-24                         |
| **Người**   | Claude (AI Agent)                  |
| **Task**    | `TEST-FE-005`                      |
| **Phase**   | Phase 6 - Flutter Testing          |
| **Loại**    | Task                               |

## Mục Tiêu

Widget test cho Comments (FR-012), Conversation List (FR-013), và Chat Detail (FR-014).

## Kết Quả

- **32 tests** — tất cả pass.
- File test: `UniShare.APP/test/features/comments_chat/comments_chat_widget_test.dart`

### CommentsScreen (13 tests)

| Test | Mô tả |
| ---- | ----- |
| renders app bar with title "Bình luận" | AppBar hiển thị đúng |
| shows loading state | `LoadingState` với message "Đang tải bình luận..." |
| shows error state with retry button | `ErrorState` với message + nút "Thử lại" |
| shows empty state when no comments | `EmptyState` "Chưa có bình luận nào" |
| shows comment list with user name and content | Dữ liệu comment hiển thị |
| shows reply/edit/delete for own comment | Authenticated user thấy Trả lời/Sửa/Xóa |
| shows guest hint text | Guest thấy "Đăng nhập để bình luận" |
| shows "Viết bình luận..." hint for authenticated | Auth user thấy hint nhập liệu |
| shows reply input bar when tapping "Trả lời" | Tap Trả lời → hiện inline reply |
| shows edit mode when tapping "Sửa" | Tap Sửa → hiện edit input |
| shows [đã xóa] for deleted comment | Soft-delete hiển thị italic + ẩn action |
| shows nested replies with threaded display | Parent + reply cùng hiển thị |
| send button is present | Icon gửi có trong bottom input |

### ConversationListScreen (7 tests)

| Test | Mô tả |
| ---- | ----- |
| renders app bar with title "Tin nhắn" | AppBar hiển thị đúng |
| shows loading state | LoadingState với message |
| shows error state with retry button | ErrorState + Thử lại |
| shows empty state when no conversations | EmptyState + subtitle |
| shows conversation list | Participant name, last message, listing context |
| shows unread badge | Badge số đếm |
| shows "về: listingTitle" | Listing context text |
| shows multiple conversations | 2 conversations render correctly |

### ChatDetailScreen (12 tests)

| Test | Mô tả |
| ---- | ----- |
| shows login prompt for unauthenticated | Guest thấy message login |
| shows loading state | LoadingState với message |
| shows error state with retry button | ErrorState + Thử lại |
| shows empty state when no messages | EmptyState + "Hãy gửi tin nhắn đầu tiên" |
| shows own message bubble on the right | Own message hiển thị + icon done |
| shows other participant message bubble | Other message hiển thị, không icon |
| shows read status icon | `Icons.done_all` cho status "Read" |
| shows message input bar with hint | "Nhập tin nhắn..." + send icon |
| shows other participant name in app bar | Tên người nhận trong AppBar |
| shows both own and other messages | 2 messages cùng hiển thị |
| shows "Xem tin nhắn cũ hơn" when hasMore | Load more button hiển thị |

## Pattern

- Sử dụng fake notifier pattern giống hệt các widget test hiện có (TEST-FE-003, TEST-FE-004).
- Provider override cho `commentsProvider` (StateNotifierProvider.family) và `chatProvider` (StateNotifierProvider.family với record key).
- Fake `SignalRService` với `implements` để phục vụ ChatNotifier constructor.
- Không dùng mocktail — giữ consistent với codebase.

## Definition of Done

- [x] 32 widget tests pass
- [x] Bao phủ các state: Loading, Empty, Error, Data
- [x] Test comment actions: Trả lời, Sửa, Xóa
- [x] Test guest restrictions
- [x] Test chat message bubbles (own vs other, sent/read status)
- [x] Test conversation list with unread badge
- [x] Không ảnh hưởng các test khác (130 tests vẫn pass)
