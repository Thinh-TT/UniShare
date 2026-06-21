# Session Log: Phase 2 - Backend API Core: Admin APIs

**Date:** 2026-06-21
**Author:** ThinhTT + Claude Code
**Status:** Completed

---

## Summary

Implemented the final task in Phase 2 — Metadata & Admin: admin-only CRUD APIs for managing Schools, Areas, and Categories. 9 endpoints protected by `[Authorize(Policy = "RequireAdmin")]`, FluentValidation input DTOs, business rule checks for duplicates, and an admin user auto-seeding mechanism for development.

## Architecture Decisions

### Decision 1: Separate IAdminService Instead of Extending IMetadataService
- **What:** Created a new `IAdminService` interface and `AdminService` class rather than adding mutation methods to `IMetadataService`.
- **Why:** `IMetadataService` is read-only and used by the public `MetadataController`. Admin CRUD operations have different semantics (mutation, duplicate validation, authorization context). Keeps interfaces small and cohesive.
- **Reference:** FR-022

### Decision 2: Roles Constants Class
- **What:** Created `Models/Enums/Roles.cs` with `const string Admin = "Admin"` and `const string User = "User"`.
- **Why:** Eliminates magic strings scattered across AuthService, ServiceCollectionExtensions, and AdminSeedService. Centralized, refactor-safe.
- **Pattern:** Replaced `"User"` in `AuthService.RegisterAsync` and `"Admin"` in `AddJwtAuthentication` policy.

### Decision 3: Idempotent Deactivation
- **What:** `DeactivateXxxAsync` returns the DTO immediately if already inactive (`!IsActive`), instead of throwing.
- **Why:** `PATCH /deactivate` is an idempotent operation — calling it multiple times should produce the same result (entity is inactive). Throwing on the second call would be surprising.

### Decision 4: Composite Uniqueness for Areas
- **What:** Area duplicate check uses `Name + City` composite key rather than just `Name`.
- **Why:** Multiple cities can each have a "Cau Giay" area. The combination of name and city is what makes an area unique in context.

### Decision 5: Runtime Admin Seeding (Not Migration Seed)
- **What:** `AdminSeedService.SeedAdminIfNotExistsAsync` runs at startup in development mode, using `IPasswordHasher` to properly hash the admin password at runtime.
- **Why:** Migration seed data cannot hash passwords (no access to `IPasswordHasher`). Runtime seeding uses real crypto. Configuration-driven via `appsettings.Development.json` so credentials can be changed without recompilation.
- **Alternative considered:** Migration seed with a hashed password — rejected because it requires hard-coding a known hash.

### Decision 6: No Hard Delete, No Reference Check
- **What:** Deactivation only sets `IsActive = false`. No hard delete is ever attempted, so no reference-checking logic is needed before deactivation.
- **Why:** FR-022 rule: "Nếu dữ liệu đã được sử dụng, quản trị viên chỉ nên chuyển IsActive = 0 thay vì xóa cứng." Since we never offer hard delete, we never need to check for references.
- **Trade-off:** Deactivated data cannot be reactivated by the admin (no PATCH /activate endpoint yet). Can be added later if needed.

## Issues & Fixes

No issues encountered — the implementation followed existing patterns exactly.

## Files Created (17)

| Category | Files |
|----------|-------|
| Constants | `Models/Enums/Roles.cs` |
| DTOs | `Models/DTOs/Metadata/{CreateSchoolRequest,UpdateSchoolRequest,CreateAreaRequest,UpdateAreaRequest,CreateCategoryRequest,UpdateCategoryRequest}.cs` |
| Validators | `Validators/Metadata/{CreateSchoolRequest,UpdateSchoolRequest,CreateAreaRequest,UpdateAreaRequest,CreateCategoryRequest,UpdateCategoryRequest}Validator.cs` |
| Services | `Services/Interfaces/IAdminService.cs`, `Services/AdminService.cs`, `Services/AdminSeedService.cs` |
| Controllers | `Controllers/AdminController.cs` |

## Files Modified (4)

| File | Change |
|------|--------|
| `Extensions/ServiceCollectionExtensions.cs` | Changed `RequireRole("Admin")` to `RequireRole(Roles.Admin)`, registered `IAdminService` and `AdminSeedService` |
| `Services/AuthService.cs` | Changed `Role = "User"` to `Role = Roles.User`, added `using UniShare.API.Models.Enums` |
| `Program.cs` | Added admin seed block before `app.Run()` |
| `appsettings.Development.json` | Added `AdminSeed` configuration section |

## Endpoints Implemented

| Method | Route | Auth | Status |
|--------|-------|------|--------|
| POST | `/api/v1/admin/schools` | Admin | ✅ |
| PUT | `/api/v1/admin/schools/{id}` | Admin | ✅ |
| PATCH | `/api/v1/admin/schools/{id}/deactivate` | Admin | ✅ |
| POST | `/api/v1/admin/areas` | Admin | ✅ |
| PUT | `/api/v1/admin/areas/{id}` | Admin | ✅ |
| PATCH | `/api/v1/admin/areas/{id}/deactivate` | Admin | ✅ |
| POST | `/api/v1/admin/categories` | Admin | ✅ |
| PUT | `/api/v1/admin/categories/{id}` | Admin | ✅ |
| PATCH | `/api/v1/admin/categories/{id}/deactivate` | Admin | ✅ |

## Verification

- ✅ `dotnet build` — 0 errors, 0 warnings
- ⏳ Manual API testing — pending (requires SQL Server running, admin user seeded at startup)
