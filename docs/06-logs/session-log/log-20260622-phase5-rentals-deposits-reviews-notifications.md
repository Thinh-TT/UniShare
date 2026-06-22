# Session Log — Phase 5.4 Rentals, Deposits, Reviews & Notifications (2026-06-22)

## Tasks Implemented

- **FE-REQ-001** — Rental Request Form ✓
- **FE-REQ-002** — My Rental Requests ✓
- **FE-REQ-003** — Rental Request Detail ✓
- **FE-DEP-001** — Deposit Status Screen ✓
- **FE-REV-001** — Review Form ✓
- **FE-NOTI-001** — Notifications Screen + Badge ✓

## Phase 5 Complete

All 16 Phase 5 tasks are now **DONE**:
- 9.1 Auth & Profile: 4/4 ✓
- 9.2 Listing Discovery & Management: 6/6 ✓
- 9.3 Interaction, Chat, Rental: 10/10 ✓

## Changes Made

### DTO Updates (to match backend flat field shapes)
- `RentalRequestDetailDto`: **NEW** — flat fields (requesterId, requesterName, requesterAvatarUrl, ownerId, ownerName, ownerAvatarUrl, deposit?), matching backend `RentalRequestDetailDto`
- `RentalRequestSummaryDto`: **NEW** — flat fields (otherParticipantId, otherParticipantName, otherParticipantAvatarUrl, role), matching backend `RentalRequestSummaryDto`
- `DepositDto`: added missing `createdAt` field
- `ReviewDto`: replaced nested `UserSummaryDto? reviewer/reviewee` with flat fields (reviewerId, reviewerName, reviewerAvatarUrl)
- `CreateReviewRequest`: removed `revieweeId` (backend infers it from rental request context)
- All `.g.dart` files regenerated via `build_runner`

### Data Layers Created
- `RentalsApi` + `RentalsRepository` — 8 methods: createRentalRequest, getMyRentalRequests, getRentalRequestDetail, acceptRequest, rejectRequest, cancelRequest, startRequest, completeRequest
- `DepositsApi` + `DepositsRepository` — 3 methods: getDepositByRequest, markDepositPaid, refundDeposit
- `ReviewsApi` + `ReviewsRepository` — 1 method: createReview
- `NotificationsApi` + `NotificationsRepository` — 4 methods: getNotifications, getUnreadCount, markRead, markAllRead

### Providers Created
- `RentalsProvider` — singleton providers for RentalsApi/RentalsRepository
- `RentalRequestFormProvider` — StateNotifier with sealed state (Initial → Submitting → Success → Error), form validation, price calculation
- `MyRequestsProvider` — StateNotifier for paginated list with role filter (requester/owner) and status filter (Pending/Accepted/Rejected/Cancelled/InProgress/Completed)
- `RentalRequestDetailProvider` — StateNotifier.family by requestId, sealed state (Loading → Loaded → Error), shared `_performAction` wrapper, current user role detection
- `DepositProvider` — StateNotifier.family by requestId, sealed state (Loading → Loaded → NotFound → Error)
- `ReviewProvider` — singleton providers, StateNotifier with form state
- `NotificationsProvider` — StateNotifier for paginated notification list + `unreadCountProvider` FutureProvider

### Screens Rewritten (6 stub → full)

1. **RentalRequestFormScreen**: date pickers (start/end), dynamic price calculation (days × pricePerDay), deposit amount display, message input, submit with loading overlay. Borrow type → price shows "Miễn phí". Edge cases: startDate ≥ today, endDate ≥ startDate, 409/403 error mapping.

2. **MyRequestsScreen**: `SegmentedButton` for role (Tất cả/Tôi gửi/Gửi đến tôi), `FilterChip` row for status, request cards with listing image, counterpart avatar+name, StatusBadge, total price. Infinite scroll via `ScrollController`, pull-to-refresh.

3. **RentalRequestDetailScreen**: Status hero with large StatusBadge, listing summary card (tappable → listing detail), participants section with "Bạn" label, date range + price breakdown, message bubble, deposit row. **Action button matrix** by role × status:

| Status | Requester | Owner |
|--------|-----------|-------|
| Pending | Cancel (danger, ConfirmDialog) | Accept (primary) + Reject (danger, ConfirmDialog) |
| Accepted | Cancel (danger, ConfirmDialog) | Start (primary, disabled if deposit pending) |
| InProgress | Complete (secondary, ConfirmDialog) | Complete (secondary, ConfirmDialog) |
| Completed | "Viết đánh giá" button | "Viết đánh giá" button |

4. **DepositStatusScreen**: Amount hero display, large StatusBadge, payment info table (provider, transaction ID, paid date, refund date). Action buttons with enable/disable rules: Mark Paid (owner, status==Pending), Refund (owner, status==Paid, ConfirmDialog).

5. **ReviewFormScreen**: Reviewee info card, 5-star tappable rating with Vietnamese labels (Tệ/Không hài lòng/Bình thường/Hài lòng/Tuyệt vời), optional comment input (max 500 chars), submit with loading overlay. Error mapping: 409 → "Đã đánh giá rồi", 403 → "Chưa hoàn tất giao dịch".

6. **NotificationsScreen**: Type-specific icons (Message/RentalRequest/Upvote/Comment/Review/System), read/unread background colors, relative time display, deep link navigation based on `referenceType` (Listing→/home/listings, RentalRequest→/requests, Message→/chat), optimistic mark-as-read, "Đã đọc tất cả" AppBar action, pull-to-refresh + infinite scroll.

### Routing Updates
- Added `request` sub-route under `/home/listings/:listingId` and `/search/listings/:listingId` → RentalRequestFormScreen (with GoRouter extra for listing metadata)
- Added `deposit` sub-route under `/requests/:requestId` and `/profile/my-requests/requests/:requestId` → DepositStatusScreen
- Added `review` sub-route under `/requests/:requestId` and `/profile/my-requests/requests/:requestId` → ReviewFormScreen (with GoRouter extra for revieweeName/revieweeAvatarUrl)

### Home Screen Modification
- Replaced simple bell `IconButton` with `Stack` + badge container
- Watches `unreadCountProvider` (FutureProvider<int>)
- Badge shows count (capped at "99+") when > 0, hidden when 0 or on error
- Invalidate `unreadCountProvider` after returning from notifications screen

### Listing Detail Screen Modification
- Replaced `_navigateToRentalRequest()` stub (SnackBar placeholder) with actual navigation passing listing title, price, deposit, and type via `context.push(..., extra: {...})`

## Key Design Decisions

1. **Flat DTO fields**: Backend returns flat objects (no nested UserSummaryDto), so new DTOs use flat fields to match. Existing nested DTOs (RentalRequestDto, ReviewDto) were updated.

2. **StateNotifier access pattern**: Form screens (RentalRequestFormScreen, ReviewFormScreen) use local `setState` instead of manually-created StateNotifier instances. This avoids protected member access issues and is the simpler pattern for ephemeral form state.

3. **Action confirmation**: Destructive actions (Cancel, Reject) use `ConfirmDialog(isDangerous: true)`. Non-destructive actions (Accept, Start, Complete) use `ConfirmDialog` with appropriate confirm labels.

4. **Optimistic updates**: Notifications `markAsRead` and `markAllAsRead` use optimistic UI updates with revert on API failure.

5. **Role-based UI**: Rental request detail screen determines current user's role (requester/owner) by comparing `currentUserId` with `requesterId`/`ownerId` from the detail DTO.

## Verification

- `dart analyze`: **0 errors** across all new code
- `build_runner`: 10 `.g.dart` files generated successfully
- Warnings: only pre-existing warnings in files not modified in this session (comments_api, conversations_api, chat_detail_screen, home_screen, listing_card, user_avatar)
- Info: standard `prefer_initializing_formals` and `unnecessary_underscores` only

## Next: Phase 6 — Flutter Testing

All 16 Phase 5 tasks complete. Ready for Phase 6 testing phase.
