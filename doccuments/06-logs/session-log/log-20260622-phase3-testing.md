# Manual Swagger/OpenAPI Verification Checklist (TEST-BE-010)

## Prerequisites
- SQL Server running with UniShare database
- API running in Development mode: `dotnet run --project UniShare.API`
- Browser open to `https://localhost:{port}/swagger`

## Step 1 — Verify Swagger UI Loads
- [ ] Swagger UI loads at `/swagger`
- [ ] All 9 API groups visible in dropdown: Auth, Users, Listings, Interactions, Chat, RentalRequests, Reviews, Notifications, Admin
- [ ] "Authorize" button visible at top-right

## Step 2 — Authentication Flow

### Register (`POST /api/v1/auth/register`)
- [ ] Register with valid data → 201 Created, response includes userId, email, fullName, reputationScore
- [ ] Register with duplicate email → 409 Conflict
- [ ] Register with invalid email format → 400 Bad Request

### Login (`POST /api/v1/auth/login`)
- [ ] Login with email → 200 OK, returns accessToken, refreshToken, user summary
- [ ] Login with phone number → 200 OK
- [ ] Login with wrong password → 401 Unauthorized
- [ ] Click "Authorize" button, paste JWT token → subsequent requests include Bearer header

### Refresh Token (`POST /api/v1/auth/refresh-token`)
- [ ] Refresh with valid token → 200 OK, new access token and refresh token
- [ ] Refresh with same token again → 401 (token was revoked/rotated)

### Logout (`POST /api/v1/auth/logout`)
- [ ] Logout with valid bearer token → 204 No Content
- [ ] Logout without token → 401 Unauthorized

## Step 3 — User Profile

- [ ] `GET /api/v1/users/me` with token → 200, returns full profile
- [ ] `PUT /api/v1/users/me` → 200, updates profile fields
- [ ] `GET /api/v1/users/{userId}` → 200, returns public summary

## Step 4 — Listings

- [ ] `GET /api/v1/listings?page=1&pageSize=20` → 200 with paged results
- [ ] `GET /api/v1/listings?keyword=laptop` → filtered results
- [ ] `GET /api/v1/listings?categoryId={id}` → category-filtered
- [ ] `POST /api/v1/listings` with auth → 201, creates listing
- [ ] `PUT /api/v1/listings/{id}` as owner → 200, updates
- [ ] `PUT /api/v1/listings/{id}` as non-owner → 403 Forbidden
- [ ] `PATCH /api/v1/listings/{id}/close` as owner → 200, status=Closed
- [ ] `DELETE /api/v1/listings/{id}` as owner → 204, soft-deletes
- [ ] `GET /api/v1/me/listings` → only own listings

## Step 5 — Interactions

- [ ] `PUT /api/v1/listings/{id}/upvote` → 200
- [ ] `DELETE /api/v1/listings/{id}/upvote` → 200
- [ ] `POST /api/v1/listings/{id}/comments` → 201
- [ ] `GET /api/v1/listings/{id}/comments` → 200 paged
- [ ] `PUT /api/v1/comments/{id}` as owner → 200
- [ ] `DELETE /api/v1/comments/{id}` as owner → 204

## Step 6 — Chat

- [ ] `POST /api/v1/listings/{id}/conversations` → 201 new / 200 existing
- [ ] `GET /api/v1/me/conversations` → 200 paged
- [ ] `POST /api/v1/conversations/{id}/messages` → 201

## Step 7 — Rental & Review Flow (E2E)

- [ ] Create listing as owner A
- [ ] Create rental request as renter B → 201 Pending
- [ ] Accept request as owner A → 200 Accepted
- [ ] Start transaction as owner A → 200 InProgress
- [ ] Complete transaction as renter B → 200 Completed
- [ ] Create review as renter B → 201
- [ ] Create review as owner A → 201
- [ ] Verify reputation scores updated

## Step 8 — Notifications

- [ ] `GET /api/v1/me/notifications` → 200 with notification items
- [ ] `GET /api/v1/me/notifications/unread-count` → 200
- [ ] `PATCH /api/v1/me/notifications/{id}/read` → 204
- [ ] `PATCH /api/v1/me/notifications/read-all` → 204

## Step 9 — Admin

- [ ] Regular user accessing `/api/v1/admin/schools` POST → 403
- [ ] Admin user accessing same endpoint → 201/200

## Step 10 — Error Response Verification

- [ ] 400: Invalid request body → ProblemDetails JSON
- [ ] 401: Missing/invalid token → ProblemDetails JSON
- [ ] 403: Non-owner mutation → ProblemDetails JSON
- [ ] 404: Non-existent resource → ProblemDetails JSON
- [ ] 409: Business rule violation → ProblemDetails JSON

## Results

| Module | Status | Notes |
|--------|--------|-------|
| Swagger UI Load | ⬜ | |
| Auth Flow | ⬜ | |
| Users | ⬜ | |
| Listings | ⬜ | |
| Interactions | ⬜ | |
| Chat | ⬜ | |
| Rental/Review | ⬜ | |
| Notifications | ⬜ | |
| Admin | ⬜ | |
| Error Responses | ⬜ | |
