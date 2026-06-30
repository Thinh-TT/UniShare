# Session Log: Phase 8 - Notification SignalR & Deep Link (P8-NOTI-001 → P8-NOTI-007)

**Date:** 2026-06-30

**Objective:** Implement notification SignalR real-time and deep link tasks P8-NOTI-001 through P8-NOTI-007.

---

## Summary

Implemented 7 tasks for real-time notification signalR connection, auto-connect lifecycle, SnackBar with deep link navigation, and removed dead notification code from the chat SignalR service.

**Build result:** 0 analyze errors, 254 tests pass (17 pre-existing failures in `rental_deposit_review_widget_test.dart` unrelated to these changes).

---

## Files Created

| File | Description |
|------|-------------|
| `UniShare.APP/lib/core/network/notification_signalr_client.dart` | **New** — `NotificationSignalRService` connecting to `/hubs/notifications`, parsing `NotificationDto` from stream |
| `UniShare.APP/lib/core/network/notification_signalr_provider.dart` | **New** — Riverpod singleton provider for `NotificationSignalRService` |

## Files Modified

| File | Action |
|------|--------|
| `UniShare.APP/lib/core/network/signalr_client.dart` | **Remove dead code** — deleted `_notificationReceivedController`, `onNotificationReceived` getter, `NotificationReceived` handler |
| `UniShare.APP/lib/features/auth/presentation/providers/auth_provider.dart` | **Modify** — inject `NotificationSignalRService`, auto-connect after login/tryAutoLogin, disconnect on logout |
| `UniShare.APP/lib/routing/main_shell.dart` | **Refactor** — converted from `StatelessWidget` to `ConsumerStatefulWidget`, subscribe notification stream, invalidate `unreadCountProvider`, show SnackBar with "Xem" navigation |
| `docs/05-tasks/01-task-board.md` | **Update** — mark P8-NOTI-* as done |
| `docs/05-tasks/02-phase-8.md` | **Update** — mark P8-NOTI-* as done |

---

## Task Details

### P8-NOTI-001 — Create NotificationSignalRService

Created `lib/core/network/notification_signalr_client.dart`:
- **Hub URL:** Derives from `AppConfig.signalrHubUrl` by replacing `/hubs/chat` → `/hubs/notifications`
- **Stream:** `onNotificationReceived` emits `NotificationDto` (parsed from JSON via `NotificationDto.fromJson`)
- **Connection state:** `onConnectionStateChanged` stream + `isConnected` getter
- **Auto-reconnect:** Uses `withAutomaticReconnect()` from signalr_netcore
- **ngrok header:** Attaches `ngrok-skip-browser-warning` for tunnel compatibility
- **Error handling:** Silent parse error → `debugPrint`; connection failure → no crash
- **Dispose pattern:** Clean disconnect + close all stream controllers

### P8-NOTI-002 — Create notificationSignalRServiceProvider

Created `lib/core/network/notification_signalr_provider.dart`:
- Riverpod `Provider<NotificationSignalRService>` singleton
- Auto-dispose on provider cleanup
- Creates its own `TokenStorage` instance (avoids circular import with `auth_provider.dart`)
- Re-exports `NotificationSignalRService` class for consumer convenience

### P8-NOTI-003 — Remove notification dead code from SignalRService

Removed from `signalr_client.dart`:
- `_notificationReceivedController` stream controller
- `onNotificationReceived` stream getter (was connecting to wrong hub `/hubs/chat`)
- `NotificationReceived` handler in `_hubConnection!.on(...)`
- `_notificationReceivedController.close()` in `dispose()`
- Updated class-level doc comment to clarify chat-only responsibility

### P8-NOTI-004 — Auto-connect/disconnect in AuthNotifier

Modified `auth_provider.dart`:
- Injected `NotificationSignalRService` as 3rd constructor parameter
- Calls `_notificationSignalR.connect()` after successful `tryAutoLogin()` (using `unawaited` for fire-and-forget)
- Calls `_notificationSignalR.connect()` after successful `login()`
- Calls `_notificationSignalR.disconnect()` before `logout()` clears auth state
- Added `import 'dart:async'` for `unawaited`

### P8-NOTI-005 — MainShell ConsumerStatefulWidget

Converted `MainShell` from `StatelessWidget` to `ConsumerStatefulWidget`:
- Subscribes to `NotificationSignalRService.onNotificationReceived` in `initState` + `addPostFrameCallback`
- On each notification arrival:
  1. Invalidates `unreadCountProvider` to refresh badge counts
  2. Shows floating SnackBar with notification title/body
- Uses `mounted` guard to prevent post-dispose state updates
- Added `onError` handler for stream errors

### P8-NOTI-006 — SnackBar with "Xem" deep link

- SnackBar appears as floating rounded card (`SnackBarBehavior.floating`, `BorderRadius.circular(12)`)
- Duration: 5 seconds
- "Xem" action navigates based on `referenceType`:
  - `listing` → `/home/listings/{referenceId}`
  - `rentalrequest` / `review` → `/requests/{referenceId}`
  - `message` → `/chat/{referenceId}`
- Hides previous SnackBar before showing new one (prevents stacking)
- Uses `context.push()` for GoRouter navigation

### P8-NOTI-007 — Verify NotificationsScreen deep link

Verified `NotificationsScreen._onTapNotification()` routes match the GoRouter configuration in `app_router.dart`:

| `referenceType` | Pushes to | Router path | Status |
|---|---|---|---|
| `listing` | `/home/listings/{id}` | `ShellRoute > /home > listings/:listingId` | ✅ |
| `rentalrequest` | `/requests/{id}` | Top-level `/requests/:requestId` | ✅ |
| `message` | `/chat/{id}` | `ShellRoute > /chat > :conversationId` | ✅ |
| `review` | `/requests/{id}` | Top-level `/requests/:requestId` | ✅ |

No code changes needed — existing routes match correctly.

---

## Architecture Notes

### Two independent SignalR services

**Chat (`SignalRService`):**
- Hub: `/hubs/chat`
- Methods: `SendMessage`, `MarkAsRead`, `JoinConversation`, `LeaveConversation`
- Events: `MessageReceived`
- Managed per-screen (chat detail screen joins/leaves groups)

**Notification (`NotificationSignalRService`):**
- Hub: `/hubs/notifications`
- Server-auto groups by userId on connect (`OnConnectedAsync`)
- Events: `NotificationReceived` (full `NotificationDto` with `referenceType` + `referenceId`)
- Managed by `AuthNotifier` lifecycle (connect on auth, disconnect on logout)
- SnackBar listening handled by `MainShell` (only mounted when authenticated)

### Circular import avoidance

`notificationSignalRServiceProvider` creates its own `TokenStorage()` instead of importing `tokenStorageProvider` from `auth_provider.dart`, preventing a circular dependency. `TokenStorage` is lightweight (FlutterSecureStorage wrapper without dependencies on auth).

---

## Build Verification

| Check | Result |
|-------|--------|
| `flutter pub get` | ✅ Pass |
| `dart run build_runner build` | ✅ Pass (0 new outputs needed) |
| `flutter analyze` | ✅ 0 errors |
| `flutter test` | ✅ 254 passed, 17 pre-existing failures |
