# Session Log — Phase 6: Flutter Testing (TEST-FE-001 & TEST-FE-002)

- **Date**: 2026-06-22
- **Performer**: AI Agent (Claude)
- **Related Tasks**: `TEST-FE-001`, `TEST-FE-002`
- **Type**: Implementation

## Summary

Completed Phase 6 tasks TEST-FE-001 (API client và DTO parsing tests) and TEST-FE-002 (Login/Register/Profile tests). Wrote 4 new test files covering 118 new tests. All 130 tests pass (including 12 pre-existing widget tests).

## Files Created

### TEST-FE-001: Unit test API client và DTO parsing

| File | Tests | Description |
|------|-------|-------------|
| `test/models/api_response_test.dart` | 56 | ApiResponse<T>, PagedResponse<T>, ProblemDetails parsing; AppException hierarchy; Auth/User/Listing/Reference/Rental/Review/Notification DTO fromJson/toJson; enum parsing (ListingType, ListingStatus, RentalRequestStatus, DepositStatus, NotificationType) |

### TEST-FE-002: Unit/widget test Login/Register/Profile

| File | Tests | Description |
|------|-------|-------------|
| `test/features/auth/auth_state_test.dart` | 8 | AuthState sealed class hierarchy, const constructors, pattern matching exhaustiveness |
| `test/features/auth/auth_form_validation_test.dart` | 27 | Pure function validation: login (email/phone), password, full name, email, phone, confirm password; complete form scenarios |
| `test/features/auth/auth_screens_widget_test.dart` | 35 | Widget tests: LoginScreen (render, validation, loading), RegisterScreen (render, validation, loading, optional phone), ProfileScreen (render content, error state), EditProfileScreen (render, error, validation with scroll) |

## Source Fixes

- **`lib/features/auth/presentation/providers/auth_state.dart`**: Added explicit `const` constructors to `AuthInitial`, `AuthLoading`, `AuthUnauthenticated` (Dart sealed class requirement per AGENT.md).

## Test Detail

### TEST-FE-001 Coverage
- `ApiResponse<T>`: success with data, null data, missing message, toJson, typed DTO
- `PagedResponse<T>`: parsing, hasMore logic (true/false/edge), empty list, typed DTOs, toJson
- `ProblemDetails`: validation errors (422), not found (404), minimal, toJson
- `AppException`: all 8 types with correct status codes
- Auth DTOs: LoginRequest, RegisterRequest (with/without phone), LoginResponse (nested user)
- User DTOs: UserProfileDto (full/minimal), UserSummaryDto, UpdateProfileRequest
- Listing DTOs: ListingSummaryDto (rent/borrow, with/without owner), ListingDetailDto (nested category/school/area/images/tags/owner)
- Reference DTOs: CategoryDto, SchoolDto, AreaDto, TagDto
- Image/Rental/Review/Notification DTOs with enum parsing

### TEST-FE-002 Coverage
- **Form validation (unit)**: All field validators tested with valid/invalid values, edge cases
- **AuthState (unit)**: Sealed class hierarchy, equality, pattern matching
- **Login screen (widget)**: UI elements, form validation errors, loading state (CircularProgressIndicator + AbsorbPointer)
- **Register screen (widget)**: UI elements, all validation rules, optional phone, loading state
- **Profile screen (widget)**: Rendered content (avatar, stats, menu), scroll to logout button, error state
- **Edit profile screen (widget)**: Pre-filled form fields, error state, name/phone validation with scroll-to-button

## Blockers / Issues Resolved

1. **`const` AuthState subclasses**: Dart sealed classes require explicit `const` constructors on subclasses. Fixed the source in `auth_state.dart`.
2. **`pumpAndSettle` timeout with loading states**: `CircularProgressIndicator` animates forever, causing timeout. Used `pump()` instead for loading state tests.
3. **`pumpAndSettle` timeout with splash screen**: The `UniShareApp` splash triggers `tryAutoLogin()` with 4s timeout. Used `pump(Duration(seconds: 5))` to flush timers before test ends.
4. **Off-screen buttons**: EditProfileScreen save button below viewport. Used `scrollUntilVisible`.
5. **Enum case mismatch**: `NotificationType` uses PascalCase in JSON (e.g., `RentalRequest`, `Message`) — tests updated accordingly.
6. **DTO `toJson` type**: `LoginResponse.toJson()` nested `user` field is a DTO object, not `Map`. Adjusted assertion.

## Test Result

```
00:04 +130: All tests passed!
```

- 130 total tests: 0 errors, 0 failures
- ~118 new tests across 4 files
- 12 pre-existing tests all still passing

## Next Steps

Phase 6 remaining tasks: `TEST-FE-003` through `TEST-FE-009`.
