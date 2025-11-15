# API Documentation

## Overview

This is the Rails API backend for the commentable platform. The API is versioned and follows RESTful principles with comprehensive filtering, sorting, and pagination support via Ransack.

**Base URL:** `/api/v1`

**Authentication:** JWT Bearer tokens

## Table of Contents

1. [Authentication](#authentication)
2. [User Management](#user-management)
3. [Videos](#videos)
4. [Posts](#posts)
5. [Comments](#comments)
6. [Reactions](#reactions)
7. [Reports](#reports)
8. [Admin Endpoints](#admin-endpoints)
9. [Ransack Filtering](#ransack-filtering)
10. [Pagination](#pagination)
11. [Error Handling](#error-handling)

---

## Authentication

### Register

**POST** `/api/v1/auth/register`

Create a new user account.

**Request Body:**
```json
{
  "email": "user@example.com",
  "username": "johndoe",
  "password": "SecurePassword123!",
  "password_confirmation": "SecurePassword123!",
  "first_name": "John",
  "last_name": "Doe"
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "johndoe",
      "full_name": "John Doe",
      "role": "user"
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiJ9...",
      "refresh_token": "eyJhbGciOiJIUzI1NiJ9..."
    }
  }
}
```

### Login

**POST** `/api/v1/auth/login`

Authenticate and receive JWT tokens.

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePassword123!"
}
```

**Response:** Same as Register

### Refresh Token

**POST** `/api/v1/auth/refresh`

Get a new access token using a refresh token.

**Request Body:**
```json
{
  "refresh_token": "eyJhbGciOiJIUzI1NiJ9..."
}
```

**Response:**
```json
{
  "success": true,
  "data": {
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiJ9...",
      "refresh_token": "eyJhbGciOiJIUzI1NiJ9..."
    }
  }
}
```

### Logout

**DELETE** `/api/v1/auth/logout`

Invalidate current session (client should discard tokens).

**Headers:**
```
Authorization: Bearer <access_token>
```

### Verify Email

**POST** `/api/v1/auth/verify_email`

Verify user email address.

**Request Body:**
```json
{
  "token": "email_verification_token"
}
```

### Forgot Password

**POST** `/api/v1/auth/forgot_password`

Request password reset email.

**Request Body:**
```json
{
  "email": "user@example.com"
}
```

### Reset Password

**POST** `/api/v1/auth/reset_password`

Reset password with token from email.

**Request Body:**
```json
{
  "token": "reset_token",
  "password": "NewSecurePassword123!",
  "password_confirmation": "NewSecurePassword123!"
}
```

---

## User Management

### List Users

**GET** `/api/v1/users`

List users with optional filtering.

**Query Parameters (Ransack):**
- `q[username_cont]=john` - Search by username
- `q[role_eq]=moderator` - Filter by role
- `q[status_eq]=active` - Filter by status
- `q[s]=created_at desc` - Sort by creation date

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "username": "johndoe",
      "full_name": "John Doe",
      "role": "user",
      "status": "active",
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 25,
    "total_pages": 10,
    "total_count": 250
  }
}
```

### Get User Profile

**GET** `/api/v1/users/:id`

Get user profile by ID or username.

**Response:**
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "email": "user@example.com",
    "username": "johndoe",
    "full_name": "John Doe",
    "bio": "Software developer",
    "avatar": "https://...",
    "role": "user",
    "status": "active",
    "created_at": "2024-01-01T00:00:00Z"
  }
}
```

### Get User Profile with Stats

**GET** `/api/v1/users/:id/profile`

Get detailed user profile with statistics.

### Get User's Videos

**GET** `/api/v1/users/:id/videos`

Get all videos by a specific user.

### Get User's Posts

**GET** `/api/v1/users/:id/posts`

Get all posts by a specific user.

### Get User's Comments

**GET** `/api/v1/users/:id/comments`

Get all comments by a specific user.

### Update User

**PATCH** `/api/v1/users/:id`

Update user profile (own account only, unless admin).

**Request Body:**
```json
{
  "user": {
    "username": "newusername",
    "first_name": "John",
    "last_name": "Doe",
    "bio": "Updated bio",
    "avatar": "https://..."
  }
}
```

### Delete User

**DELETE** `/api/v1/users/:id`

Soft delete user account (own account only, unless admin).

---

## Videos

### List Videos

**GET** `/api/v1/videos`

List videos with Ransack filtering.

**Query Parameters (Ransack):**
- `q[title_cont]=rails` - Search by title
- `q[status_eq]=published` - Filter by status
- `q[visibility_eq]=public` - Filter by visibility
- `q[tags_cont]=tutorial` - Search in tags
- `q[user_username_eq]=john` - Filter by username
- `q[created_at_gteq]=2024-01-01` - Created after date
- `q[s]=views_count desc` - Sort by views (descending)

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "title": "Rails Tutorial",
      "description": "Learn Rails",
      "url": "https://...",
      "thumbnail_url": "https://...",
      "duration": 3600,
      "status": "published",
      "visibility": "public",
      "tags": ["rails", "tutorial"],
      "views_count": 1000,
      "comments_count": 50,
      "reactions_count": 100,
      "user": {
        "id": "uuid",
        "username": "johndoe"
      },
      "created_at": "2024-01-01T00:00:00Z"
    }
  ],
  "meta": {
    "current_page": 1,
    "per_page": 25,
    "total_pages": 10,
    "total_count": 250
  }
}
```

### Get Video

**GET** `/api/v1/videos/:id`

Get single video by ID. Increments view count.

### Create Video

**POST** `/api/v1/videos`

Create a new video (authenticated users only).

**Headers:**
```
Authorization: Bearer <access_token>
```

**Request Body:**
```json
{
  "video": {
    "title": "Rails Tutorial",
    "description": "Learn Rails basics",
    "url": "https://youtube.com/...",
    "thumbnail_url": "https://...",
    "duration": 3600,
    "status": "draft",
    "visibility": "private",
    "tags": ["rails", "tutorial"],
    "metadata": {
      "resolution": "1080p",
      "platform": "youtube"
    }
  }
}
```

### Update Video

**PATCH** `/api/v1/videos/:id`

Update video (owner or moderator only).

### Delete Video

**DELETE** `/api/v1/videos/:id`

Soft delete video (owner or moderator only).

### Publish Video

**POST** `/api/v1/videos/:id/publish`

Publish a draft video.

### Archive Video

**POST** `/api/v1/videos/:id/archive`

Archive a published video.

---

## Posts

### List Posts

**GET** `/api/v1/posts`

List posts with Ransack filtering.

**Query Parameters (Ransack):**
- `q[title_or_content_cont]=rails` - Search in title or content
- `q[status_eq]=published` - Filter by status
- `q[visibility_eq]=public` - Filter by visibility
- `q[tags_cont]=tutorial` - Search in tags
- `q[s]=published_at desc` - Sort by publish date

**Note:** Content is excluded in list view for performance.

### Get Post

**GET** `/api/v1/posts/:id`

Get single post by ID or slug. Increments view count.

### Create Post

**POST** `/api/v1/posts`

Create a new post (authenticated users only).

**Request Body:**
```json
{
  "post": {
    "title": "Understanding Rails",
    "content": "Full markdown content...",
    "excerpt": "Short summary",
    "featured_image_url": "https://...",
    "status": "draft",
    "visibility": "private",
    "tags": ["rails", "tutorial"],
    "metadata": {
      "reading_time": 5
    }
  }
}
```

### Update Post

**PATCH** `/api/v1/posts/:id`

Update post (owner or moderator only).

### Delete Post

**DELETE** `/api/v1/posts/:id`

Soft delete post (owner or moderator only).

### Publish Post

**POST** `/api/v1/posts/:id/publish`

Publish a draft post.

### Archive Post

**POST** `/api/v1/posts/:id/archive`

Archive a published post.

---

## Comments

### List Comments

**GET** `/api/v1/comments`

List all comments with Ransack filtering.

**GET** `/api/v1/videos/:video_id/comments`

List comments on a specific video.

**GET** `/api/v1/posts/:post_id/comments`

List comments on a specific post.

**Query Parameters (Ransack):**
- `q[content_cont]=great` - Search in content
- `q[status_eq]=active` - Filter by status
- `q[commentable_type_eq]=Video` - Filter by entity type
- `q[user_username_cont]=john` - Filter by username
- `q[parent_id_null]=true` - Only top-level comments
- `q[s]=created_at desc` - Sort by date

### Get Comment

**GET** `/api/v1/comments/:id`

Get single comment with optional nested replies.

**Query Parameters:**
- `include_replies=true` - Include nested replies

### Create Comment

**POST** `/api/v1/videos/:video_id/comments`
**POST** `/api/v1/posts/:post_id/comments`

Create a comment on a video or post.

**Request Body:**
```json
{
  "comment": {
    "content": "Great video!",
    "status": "active"
  }
}
```

### Create Reply

**POST** `/api/v1/comments/:id/replies`

Create a nested reply to a comment.

**Request Body:**
```json
{
  "comment": {
    "content": "Thanks!"
  }
}
```

### Update Comment

**PATCH** `/api/v1/comments/:id`

Update comment (owner or moderator only).

### Delete Comment

**DELETE** `/api/v1/comments/:id`

Soft delete comment (owner or moderator only).

---

## Reactions

### List Reactions

**GET** `/api/v1/reactions`

List all reactions with Ransack filtering.

**GET** `/api/v1/videos/:video_id/reactions`
**GET** `/api/v1/posts/:post_id/reactions`
**GET** `/api/v1/comments/:comment_id/reactions`

List reactions on a specific entity.

**Query Parameters (Ransack):**
- `q[type_name_eq]=like` - Filter by reaction type
- `q[reactable_type_eq]=Video` - Filter by entity type
- `q[user_username_cont]=john` - Filter by username
- `summary=true` - Get reaction summary instead of list

**Summary Response:**
```json
{
  "success": true,
  "data": {
    "summary": {
      "like": 100,
      "love": 50,
      "clap": 25,
      "dislike": 5
    },
    "total": 180
  }
}
```

### Create Reaction

**POST** `/api/v1/videos/:video_id/reactions`
**POST** `/api/v1/posts/:post_id/reactions`
**POST** `/api/v1/comments/:comment_id/reactions`

Add or toggle a reaction (authenticated users only).

**Request Body:**
```json
{
  "reaction": {
    "type_name": "like"
  }
}
```

**Types:** `like`, `dislike`, `love`, `clap`

**Note:** Creating a reaction with the same type removes it (toggle). Different reaction types replace the previous one (one reaction per user per entity).

### Delete Reaction

**DELETE** `/api/v1/reactions/:id`

Remove a reaction (owner only).

---

## Reports

### List Reports

**GET** `/api/v1/reports`

List reports. Regular users see only their own reports; moderators see all.

**Query Parameters (Ransack):**
- `q[status_eq]=pending` - Filter by status
- `q[reason_eq]=spam` - Filter by reason
- `q[reportable_type_eq]=Comment` - Filter by entity type

### Get Report

**GET** `/api/v1/reports/:id`

Get detailed report (owner or moderator only).

### Create Report

**POST** `/api/v1/reports`

Create a report (authenticated users only).

**Request Body:**
```json
{
  "reportable_type": "Comment",
  "reportable_id": "uuid",
  "report": {
    "reason": "spam",
    "description": "This is spam content"
  }
}
```

**Reasons:** `spam`, `harassment`, `inappropriate`, `copyright`, `other`

### Update Report

**PATCH** `/api/v1/reports/:id`

Update report notes (moderator only).

**Request Body:**
```json
{
  "report": {
    "moderator_notes": "Investigated and confirmed"
  }
}
```

### Review Report

**POST** `/api/v1/reports/:id/review`

Mark report as under review (moderator only).

### Resolve Report

**POST** `/api/v1/reports/:id/resolve`

Resolve report with optional moderation action (moderator only).

**Request Body:**
```json
{
  "moderator_notes": "Content removed",
  "action_type": "delete"
}
```

**Action Types:** `hide`, `delete`, `flag`, `suspend_user`

### Reject Report

**POST** `/api/v1/reports/:id/reject`

Reject report as invalid (moderator only).

**Request Body:**
```json
{
  "moderator_notes": "Not a violation"
}
```

---

## Admin Endpoints

All admin endpoints require moderator or admin role.

### Admin Users

#### List All Users

**GET** `/api/v1/admin/users`

List all users including soft deleted.

**Query Parameters (Ransack):**
- `q[deleted_at_not_null]=true` - Show deleted users only
- All standard user filters

#### Get User Details

**GET** `/api/v1/admin/users/:id`

Get detailed user information with statistics and audit trail.

#### Update User

**PATCH** `/api/v1/admin/users/:id`

Update user (admins can change role, status).

**Request Body (Admin):**
```json
{
  "user": {
    "role": "moderator",
    "status": "active",
    "email_verified": true
  }
}
```

#### Delete User

**DELETE** `/api/v1/admin/users/:id`

Soft delete user (admin only).

#### Suspend User

**POST** `/api/v1/admin/users/:id/suspend`

Suspend user account.

**Request Body:**
```json
{
  "reason": "Terms of service violation"
}
```

#### Activate User

**POST** `/api/v1/admin/users/:id/activate`

Activate suspended user.

### Admin Reports

#### List All Reports

**GET** `/api/v1/admin/reports`

List all reports with comprehensive statistics.

#### Get Report Details

**GET** `/api/v1/admin/reports/:id`

Get detailed report with audit trail and related reports.

#### Update Report

**PATCH** `/api/v1/admin/reports/:id`

Update report with moderator assignment and notes.

### Admin Audit Logs

#### List Audit Logs

**GET** `/api/v1/admin/audit_logs`

List immutable audit trail.

**Query Parameters (Ransack):**
- `q[action_eq]=create` - Filter by action
- `q[auditable_type_eq]=User` - Filter by entity type
- `q[user_id_eq]=uuid` - Filter by user
- `q[created_at_gteq]=2024-01-01` - Filter by date

#### Get Audit Log

**GET** `/api/v1/admin/audit_logs/:id`

Get detailed audit log entry with related logs.

### Admin Statistics

#### Platform Overview

**GET** `/api/v1/admin/statistics/overview`

Comprehensive platform statistics including:
- User counts by role, status
- Content counts by type, status
- Engagement metrics
- Moderation statistics
- Audit trail summary

#### User Statistics

**GET** `/api/v1/admin/statistics/users`

Detailed user metrics and growth trends.

**Query Parameters:**
- `days=30` - Time range for trends (default: 30)

**Response includes:**
- Daily user registrations
- User retention rates
- Top contributors
- Engagement metrics

#### Content Statistics

**GET** `/api/v1/admin/statistics/content`

Detailed content metrics and engagement.

**Query Parameters:**
- `days=30` - Time range for trends (default: 30)

**Response includes:**
- Daily content creation
- Top content by views
- Engagement rates
- Reaction distribution

---

## Ransack Filtering

All index endpoints support advanced filtering and sorting via Ransack.

### Predicates

- `eq` - Equals
- `cont` - Contains (case-insensitive)
- `start` - Starts with
- `end` - Ends with
- `gt` / `lt` - Greater than / Less than
- `gteq` / `lteq` - Greater/Less than or equal
- `in` - In array
- `null` - Is null
- `not_null` - Is not null

### Examples

```
# Search by title containing "rails"
GET /api/v1/videos?q[title_cont]=rails

# Filter by status and visibility
GET /api/v1/videos?q[status_eq]=published&q[visibility_eq]=public

# Multiple values (OR)
GET /api/v1/reactions?q[type_name_in][]=like&q[type_name_in][]=love

# Date range
GET /api/v1/posts?q[created_at_gteq]=2024-01-01&q[created_at_lteq]=2024-12-31

# Search across multiple fields (OR)
GET /api/v1/posts?q[title_or_content_cont]=rails

# Sort by field
GET /api/v1/videos?q[s]=views_count desc

# Multiple sorts
GET /api/v1/posts?q[s][]=published_at desc&q[s][]=views_count desc
```

### Association Filtering

```
# Filter by user's username
GET /api/v1/videos?q[user_username_cont]=john

# Filter comments by commentable type
GET /api/v1/comments?q[commentable_type_eq]=Video
```

---

## Pagination

All list endpoints support pagination via Kaminari.

### Query Parameters

- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 25, max: 100)

### Example

```
GET /api/v1/videos?page=2&per_page=50
```

### Response Meta

```json
{
  "meta": {
    "current_page": 2,
    "per_page": 50,
    "total_pages": 10,
    "total_count": 500
  }
}
```

---

## Error Handling

### Error Response Format

```json
{
  "success": false,
  "error": {
    "message": "Error description",
    "code": "ERROR_CODE",
    "status": 422
  }
}
```

### HTTP Status Codes

- `200` - Success
- `201` - Created
- `400` - Bad Request
- `401` - Unauthorized (authentication required)
- `403` - Forbidden (insufficient permissions)
- `404` - Not Found
- `422` - Unprocessable Entity (validation errors)
- `500` - Internal Server Error

### Common Error Codes

- `AUTHENTICATION_REQUIRED` - No valid token provided
- `INVALID_CREDENTIALS` - Wrong email/password
- `FORBIDDEN` - Insufficient permissions
- `NOT_FOUND` - Resource not found
- `VALIDATION_ERROR` - Invalid input data
- `INVALID_STATE_TRANSITION` - Cannot perform action in current state
- `DUPLICATE_REPORT` - Already reported this content

---

## Rate Limiting

Rate limiting is enforced via `rack-attack`.

**Limits:**
- Authentication endpoints: 5 requests per minute
- API endpoints (authenticated): 100 requests per minute
- API endpoints (unauthenticated): 30 requests per minute

**Headers:**
```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000
```

---

## Best Practices

1. **Always use HTTPS** in production
2. **Store tokens securely** (HttpOnly cookies or secure storage)
3. **Refresh tokens proactively** before expiration
4. **Use pagination** for large datasets
5. **Apply filters** to reduce response size
6. **Cache responses** where appropriate
7. **Handle errors gracefully** with retry logic
8. **Respect rate limits** to avoid throttling

---

## Contact & Support

For API issues, please report at: https://github.com/anthropics/claude-code/issues
