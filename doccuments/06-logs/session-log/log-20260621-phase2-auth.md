# Session Log: Phase 2 - Backend API Core: Auth & User

**Date:** 2026-06-21
**Author:** ThinhTT + Claude Code
**Status:** Completed

---

## Summary

Implemented complete Auth and User API endpoints with JWT authentication, refresh token rotation, password hashing with BCrypt, and user profile management.

## Architecture Decisions

### Decision 1: Refresh Token Storage in Database
- **What:** Created `RefreshTokens` table to persist refresh tokens server-side
- **Why:** Enables token rotation (revoke old, issue new), logout invalidation, and audit trail. In-memory storage would lose tokens on restart.
- **Trade-off:** Additional DB query per refresh vs. simpler architecture

### Decision 2: Token Rotation on Refresh
- **What:** Each refresh token use revokes the old token and issues a new pair
- **Why:** Limits window of vulnerability if a refresh token is stolen. The revoked token cannot be reused.
- **Reference:** FR-002

### Decision 3: Custom DomainException Hierarchy
- **What:** Abstract `DomainException` with `StatusCode` + 6 subclasses
- **Why:** Enables the `ExceptionHandlingMiddleware` to return proper HTTP status codes (401/403/404/409) instead of always 500. Cleaner than checking exception types by string.
- **Pattern:** Each business rule violation throws a typed exception caught by middleware.

### Decision 4: BCrypt Work Factor 12
- **What:** Password hashing uses BCrypt.Net-Next with work factor 12
- **Why:** Balanced security (~250ms hash time) and API performance. Industry standard for .NET without Identity.
- **Alternative considered:** ASP.NET Core Identity PasswordHasher (pulled from Identity package) — rejected because project uses no Identity.

### Decision 5: Role as String on User Entity
- **What:** Added `Role` column (nvarchar(20), default "User") to Users table
- **Why:** Simpler than a separate UserRoles join table for a system with only two roles (User, Admin). Can be migrated to a proper roles system later if needed.

### Decision 6: Generic Login Field
- **What:** `POST /auth/login` accepts `login` field that can be email OR phone number
- **Why:** Mobile-first UX — users shouldn't need to remember which credential they used. Detection: if `login` contains `@`, treat as email; otherwise treat as phone.

## Issues & Fixes

### Issue 1: SQL Server NULL in Unique Constraint
- **Problem:** `UserConfiguration` had `HasIndex(e => e.PhoneNumber).IsUnique()` without a filter. SQL Server treats NULL as a value in unique constraints, so only one user could have NULL phone number.
- **Fix:** Added `.HasFilter("[PhoneNumber] IS NOT NULL")` to the unique index.

### Issue 2: ResponseWrapperFilter Generic Invariance
- **Problem:** The filter checked `objectResult.Value is PagedResponse<object>` which never matched `PagedResponse<UserReviewDto>` due to C# generic invariance.
- **Fix:** Changed to `GetType().IsGenericType && GetType().GetGenericTypeDefinition() == typeof(PagedResponse<>)`.

## Files Created (28)

| Category | Files |
|----------|-------|
| Exceptions | `Exceptions/DomainException.cs` |
| Entities | `Models/Entities/RefreshToken.cs` |
| Configurations | `Data/Configurations/RefreshTokenConfiguration.cs` |
| Services | `Services/Interfaces/IPasswordHasher.cs`, `Services/PasswordHasher.cs` |
| Services | `Services/Interfaces/IAuthService.cs`, `Services/AuthService.cs` |
| Services | `Services/Interfaces/IUserService.cs`, `Services/UserService.cs` |
| Services | `Services/Interfaces/IMetadataService.cs`, `Services/MetadataService.cs` |
| DTOs (Auth) | `Models/DTOs/Auth/{RegisterRequest,LoginRequest,RefreshTokenRequest,RegisterResponse,LoginResponse,RefreshTokenResponse}.cs` |
| DTOs (Users) | `Models/DTOs/Users/{UserSummaryDto,UserProfileResponse,UpdateProfileRequest,UserReviewDto}.cs` |
| DTOs (Metadata) | `Models/DTOs/Metadata/{SchoolDto,AreaDto}.cs` |
| Validators | `Validators/Auth/{RegisterRequest,LoginRequest,RefreshTokenRequest}Validator.cs`, `Validators/Users/UpdateProfileRequestValidator.cs` |
| Controllers | `Controllers/UsersController.cs`, `Controllers/MetadataController.cs` |

## Files Modified (7)

| File | Change |
|------|--------|
| `UniShare.API.csproj` | Added BCrypt.Net-Next v4.0.3 |
| `Models/Entities/User.cs` | Added `Role` property |
| `Data/Configurations/UserConfiguration.cs` | Added Role config, fixed phone index filter |
| `Data/AppDbContext.cs` | Added `DbSet<RefreshToken>` |
| `Filters/ResponseWrapperFilter.cs` | Fixed PagedResponse generic invariance |
| `Middleware/ExceptionHandlingMiddleware.cs` | Added DomainException handler |
| `Extensions/ServiceCollectionExtensions.cs` | Added `AddApplicationServices()` |
| `Program.cs` | Called `AddApplicationServices()` |
| `Controllers/AuthController.cs` | Replaced ping with 4 real endpoints |

## Migration

- `20260621145715_AddRefreshTokenAndRole` — Adds `Role` column to `Users`, creates `RefreshTokens` table

## Endpoints Implemented

| Method | Route | Auth | Status |
|--------|-------|------|--------|
| POST | `/api/v1/auth/register` | Anonymous | ✅ |
| POST | `/api/v1/auth/login` | Anonymous | ✅ |
| POST | `/api/v1/auth/refresh-token` | Anonymous | ✅ |
| POST | `/api/v1/auth/logout` | Authorized | ✅ |
| GET | `/api/v1/users/me` | Authorized | ✅ |
| PUT | `/api/v1/users/me` | Authorized | ✅ |
| GET | `/api/v1/users/{userId}` | Anonymous | ✅ |
| GET | `/api/v1/users/{userId}/reviews` | Anonymous | ✅ |
| GET | `/api/v1/schools` | Anonymous | ✅ |
| GET | `/api/v1/areas` | Anonymous | ✅ |

## Verification

- ✅ `dotnet build` — 0 errors, 0 warnings
- ✅ Migration generated successfully
- ⏳ `dotnet ef database update` — pending (requires SQL Server running)
- ⏳ Manual API testing — pending (requires app running)
