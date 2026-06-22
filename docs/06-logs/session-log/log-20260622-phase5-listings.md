# Session Log — Phase 5.2: Listing Discovery & Management

- **Date:** 2026-06-22
- **Phase:** 5.2 — Flutter UI Screens: Listing Discovery & Management
- **Status:** DONE

## Tasks Completed

| ID | Task | Screen | Use Cases |
|----|------|--------|-----------|
| `FE-LIST-001` | Build Home/Listings screen | `home_screen.dart` | FR-009, FR-010 |
| `FE-LIST-002` | Build Search + Filter bottom sheet | `search_screen.dart` + `filter_bottom_sheet.dart` | FR-010 |
| `FE-LIST-003` | Build Listing Detail screen | `listing_detail_screen.dart` | FR-004, FR-009, FR-011, FR-015 |
| `FE-LIST-004` | Build Create Listing form | `create_listing_screen.dart` | FR-005, FR-008 |
| `FE-LIST-005` | Build Edit Listing + My Listings | `edit_listing_screen.dart` + `my_listings_screen.dart` | FR-006, FR-008 |
| `FE-LIST-006` | Build Manage Images screen | `manage_images_screen.dart` | FR-007 |

## New Files Created

### Data Layer (3 new + 2 modified)
| File | Action |
|------|--------|
| `lib/features/listings/data/listings_api.dart` | NEW — 8 API methods: getListings (paged+filtered), getListingDetail, createListing, updateListing, closeListing, deleteListing, getMyListings, toggleUpvote |
| `lib/features/listings/data/listings_repository.dart` | NEW — Thin orchestration delegating to ListingsApi |
| `lib/features/images/data/images_api.dart` | NEW — 5 methods: getImages, uploadImages (multipart), setCoverImage, reorderImages, deleteImage |
| `lib/features/reference/data/reference_api.dart` | EDIT — Added getCategories(), getTags() |
| `lib/features/reference/presentation/providers/reference_provider.dart` | EDIT — Added categoriesProvider, tagsProvider (FutureProvider) |

### Provider Layer (4 new)
| File | Description |
|------|-------------|
| `lib/features/listings/presentation/providers/listings_provider.dart` | NEW — `listingsApiProvider` → `listingsRepositoryProvider` → `listingsProvider` (FutureProvider.family by ListingFilterParams), `listingDetailProvider` (FutureProvider.family by listingId). `ListingFilterParams` value class với copyWith. |
| `lib/features/listings/presentation/providers/my_listings_provider.dart` | NEW — `StateNotifierProvider<MyListingsNotifier, MyListingsState>` với status filtering, loadMore pagination, close/delete actions optimistic update |
| `lib/features/listings/presentation/providers/listing_form_provider.dart` | NEW — `StateNotifierProvider<ListingFormNotifier, ListingFormState>` cho Create/Edit form. Key rules: borrow → auto-zero price+deposit; validate title/description/category required. |
| `lib/features/images/presentation/providers/images_provider.dart` | NEW — `StateNotifierProvider.family<ImagesNotifier, ImagesState, String>` cho image grid management (load, upload, setCover, delete, reorder) |

### Widgets (1 new)
| File | Description |
|------|-------------|
| `lib/features/listings/presentation/widgets/filter_bottom_sheet.dart` | NEW — Reusable bottom sheet với category chips (from categoriesProvider), school/area pickers, listing type toggle, price range inputs. Apply/Reset buttons. |

### Screens (7 replaced from stubs)
| File | Screen | Key Features |
|------|--------|-------------|
| `lib/features/listings/presentation/screens/home_screen.dart` | Home / Listing Feed | Search bar (read-only → /search), quick filter chips (school/area từ user profile), ListingCard list với pull-to-refresh, notification bell, loading/empty/error states, pagination |
| `lib/features/listings/presentation/screens/search_screen.dart` | Search + Filter | Search input với 300ms debounce, filter button → FilterBottomSheet, active filter chips (removable), result count, pagination |
| `lib/features/listings/presentation/screens/listing_detail_screen.dart` | Listing Detail | Image carousel (PageView + dot indicators + counter), listing info, owner card (→ public profile), stats row, action bar: upvote, comment, chat, CTA "Gửi yêu cầu". Business rules: owner ẩn CTA, status≠Available disable CTA, guest → LoginRequiredModal |
| `lib/features/listings/presentation/screens/create_listing_screen.dart` | Create Listing | Form với AppBottomSheet pickers (category/school/area), SegmentedButton rent/borrow, borrow auto-zeroes price+deposit, tag input, validation messages. Submit → navigate to ManageImages with listingId via extra |
| `lib/features/listings/presentation/screens/my_listings_screen.dart` | My Listings | Status filter chips (Tất cả/Available/Reserved/InUse/Closed), ListingCard với StatusBadge + action buttons (edit/close/delete theo status), ConfirmDialog cho close/delete, empty state với CTA |
| `lib/features/listings/presentation/screens/edit_listing_screen.dart` | Edit Listing | Form giống Create pre-filled từ listingDetailProvider. PopupMenu cho Manage Images / Close / Delete. Sử dụng listingFormProvider.shared với loadExistingListing() |
| `lib/features/images/presentation/screens/manage_images_screen.dart` | Manage Images | Nhận listingId qua GoRouter extra. GridView 3 cột với CachedNetworkImage, cover badge overlay, delete button overlay. FAB thêm ảnh qua image_picker. Set cover bằng tap, xóa confirm. |

## Architecture Decisions

1. **Provider architecture**: Follows existing 3-tier pattern (Api → Repository → Provider). FutureProvider for read-once data, StateNotifierProvider for mutable state.
2. **Filter params**: `ListingFilterParams` value class with `copyWith` and `clear*` boolean flags — avoids freezed dependency while keeping immutable update pattern.
3. **Form sharing**: Create and Edit share the same `listingFormProvider` (StateNotifier). Edit calls `loadExistingListing()` to pre-fill; Create uses default state.
4. **ManageImages listingId**: Passed via GoRouter `extra` parameter — avoids polluting route paths or creating a temporary provider.
5. **Borrow auto-zero**: When listing type changes to borrow, the form notifier sets pricePerDay=0 and depositAmount=0. UI layer reads state.listingType to disable the price field.
6. **Optimistic updates**: MyListings close/delete and Images reorder apply local state changes before API returns. On failure, error message is shown.

## Business Rules Implemented

- Guest tapping upvote/comment/chat/request → `LoginRequiredModal`
- Owner doesn't see "Gửi yêu cầu" CTA on own listings (check `listing.owner.id == currentUser.id`)
- Listing status ≠ Available → CTA disabled
- Borrow type → price auto-zero, price field disabled, deposit hidden
- My Listings: edit only available → available, close only available → available, delete only available → closed
- Create Listing: category/school/area pickers only show active data from reference providers

## Verification

- **`dart analyze`**: 0 errors, 0 warnings
- **`flutter test`**: 11/11 tests pass (all existing)
- **Pre-existing info notes**: 46 (style suggestions only, no regressions)

## Files Summary

**Total: 17 files** (11 new, 2 modified, 7 replaced stubs, -3 placeholder files removed in spirit)

## Next Phase

**Phase 5.3** — Interaction, Chat, Rental (10 tasks: FE-INT-001 through FE-NOTI-001):
- FE-INT-001: Upvote action
- FE-INT-002: Comments screen
- FE-CHAT-001/002: Conversation List + Chat Detail
- FE-REQ-001/002/003: Rental Request Form / My Requests / Request Detail
- FE-DEP-001: Deposit Status
- FE-REV-001: Review Form
- FE-NOTI-001: Notifications screen + badge
