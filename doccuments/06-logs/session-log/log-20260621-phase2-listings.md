# Session Log: Phase 2 - Backend API Core: Listing Discovery & Management

**Date:** 2026-06-21
**Author:** ThinhTT + Claude Code
**Status:** Completed

---

## Summary

Implemented the Listing Discovery & Management sub-section of Phase 2: metadata completion (categories, tags), full listing CRUD with search/filter/sort/pagination, image upload with local file storage, and all supporting DTOs/validators. Total 13 new API endpoints across metadata and listings.

## Architecture Decisions

### Decision 1: Tag Auto-Normalization (Find-or-Create)
- **What:** When creating/updating listings, tag names are slugified (lowercase, remove diacritics, replace non-alphanumeric with hyphens) and looked up by slug. New tags are created for unrecognized slugs.
- **Why:** Prevents duplicate tags with different casing/spacing (e.g., "Casio" vs "casio" vs "casio "). Slugs are the canonical key. Tag entities serve as a controlled vocabulary that grows organically.
- **Trade-off:** Extra query per create/update vs. consistent tag taxonomy
- **Reference:** FR-008

### Decision 2: Local File Storage with Relative URLs
- **What:** Images saved to `wwwroot/uploads/listings/{listingId}/{guid}.{ext}`. `ImageUrl` in DB stores relative paths like `/uploads/listings/{listingId}/{guid}.jpg`. Served via `UseStaticFiles()`.
- **Why:** Simple for MVP. No external blob storage dependency. Relative URLs work across environments (dev, staging, prod) as long as the static file middleware is configured.
- **Trade-off:** Doesn't scale horizontally (each server has its own files). Cloud blob storage (S3/Azure Blob) recommended before production.
- **Reference:** FR-007

### Decision 3: Cover Image as Boolean Flag (Not Separate Entity)
- **What:** `ListingImage.IsCover` boolean marks the cover image. Only one image per listing has `IsCover = true`. The first uploaded image auto-becomes cover.
- **Why:** Simpler than a separate `CoverImageId` FK on Listing or a separate entity. Setting a new cover just flips booleans.
- **Trade-off:** Must manually ensure exactly one cover per listing at the application layer (no DB constraint for "exactly one true per listing").
- **Reference:** FR-007

### Decision 4: View Count Incremented on Detail View
- **What:** `GET /listings/{id}` increments `ViewCount` and saves immediately.
- **Why:** Tracks listing popularity for sorting and analytics. Inline with the entity design (ViewCount is denormalized on the Listing row).
- **Trade-off:** Write on every detail read — adds latency and DB writes. May benefit from async/background increment later.
- **Reference:** FR-009

### Decision 5: Composite Search with EF Core LINQ
- **What:** `SearchListingsAsync` builds a dynamic IQueryable chain: keyword → `Contains` on Title/Description, then optional filters by CategoryId, TagId, SchoolId, AreaId, ListingType, price range, then sort by Newest/PriceAsc/PriceDesc/MostUpvotes.
- **Why:** All filters compose efficiently into a single SQL query via EF Core translation. No stored procedures needed for MVP.
- **Trade-off:** `Contains` translates to `LIKE '%keyword%'` which cannot use indexes efficiently. Full-Text Search index recommended for production scale.
- **Reference:** FR-010

### Decision 6: Business Rule Violations as DomainException (409 Conflict)
- **What:** Added `ForbiddenException` (403) and `BusinessRuleViolationException` (409) to the DomainException hierarchy. Used for ownership checks and business constraints (max images, active rental blocks, etc.).
- **Why:** Extends the existing exception pattern consistently. Middleware already maps 403 → "Forbidden" and 409 → "Conflict" in problem+json responses.
- **Pattern:** All ownership violations → 403. All business rule violations (state conflicts) → 409.

## Issues & Fixes

### Issue 1: ListingDetailDto Using Alias Placement
- **Problem:** `using TagDto = ...` alias was placed at the bottom of the file (after the namespace closing brace). C# requires using directives at the top.
- **Fix:** Moved the alias directive to line 1, before the namespace declaration.

## Files Created (16)

| Category | Files |
|----------|-------|
| DTOs (Metadata) | `Models/DTOs/Metadata/{CategoryDto,TagDto}.cs` |
| DTOs (Listings) | `Models/DTOs/Listings/{ListingSummaryDto,ListingDetailDto,CreateListingRequest,UpdateListingRequest,ListingFilterParams,ListingImageDto,ReorderImagesRequest}.cs` |
| Validators | `Validators/Listings/{CreateListingRequestValidator,UpdateListingRequestValidator}.cs` |
| Services | `Services/Interfaces/{IListingService,IListingImageService}.cs`, `Services/{ListingService,ListingImageService}.cs` |
| Controllers | `Controllers/ListingsController.cs` |

## Files Modified (6)

| File | Change |
|------|--------|
| `Services/Interfaces/IMetadataService.cs` | Added `GetActiveCategoriesAsync`, `GetTagsAsync` |
| `Services/MetadataService.cs` | Implemented categories query + paginated tag search with keyword |
| `Controllers/MetadataController.cs` | Added `GET /categories`, `GET /tags` endpoints |
| `Extensions/ServiceCollectionExtensions.cs` | Registered `IListingService`, `IListingImageService` |
| `Program.cs` | Added `app.UseStaticFiles()` for serving uploaded images |
| `Exceptions/DomainException.cs` | Added `ForbiddenException` (403), `BusinessRuleViolationException` (409) |

## Endpoints Implemented

| Method | Route | Auth | Status |
|--------|-------|------|--------|
| GET | `/api/v1/categories` | Anonymous | ✅ |
| GET | `/api/v1/tags` | Anonymous | ✅ |
| GET | `/api/v1/listings` | Anonymous | ✅ |
| GET | `/api/v1/listings/{listingId}` | Anonymous | ✅ |
| POST | `/api/v1/listings` | Authorized | ✅ |
| PUT | `/api/v1/listings/{listingId}` | Authorized | ✅ |
| PATCH | `/api/v1/listings/{listingId}/close` | Authorized | ✅ |
| DELETE | `/api/v1/listings/{listingId}` | Authorized | ✅ |
| GET | `/api/v1/me/listings` | Authorized | ✅ |
| POST | `/api/v1/listings/{listingId}/images` | Authorized | ✅ |
| PATCH | `/api/v1/listings/{listingId}/images/{imageId}/cover` | Authorized | ✅ |
| PUT | `/api/v1/listings/{listingId}/images/order` | Authorized | ✅ |
| DELETE | `/api/v1/listings/{listingId}/images/{imageId}` | Authorized | ✅ |

**Total new endpoints: 13** (2 metadata + 7 listings + 4 images)

## Verification

- ✅ `dotnet build` — 0 errors, 0 warnings
- ⏳ `dotnet ef database update` — pending (requires SQL Server running)
- ⏳ Manual API testing — pending (requires app running)
