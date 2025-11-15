# API Documentation

Welcome to the Rails Next.js Commentable Project API documentation.

## Quick Start

### Base URL

```
Development: http://localhost:3000/api/v1
Production:  https://api.yourdomain.com/api/v1
```

### Health Check

```bash
curl http://localhost:3000/api/v1/health
```

Response:
```json
{
  "success": true,
  "data": {
    "status": "healthy",
    "version": "v1",
    "timestamp": "2024-01-01T00:00:00Z",
    "environment": "development",
    "database": "connected",
    "redis": "connected"
  }
}
```

## Authentication

The API uses JWT (JSON Web Tokens) for authentication.

### Register

```bash
POST /api/v1/auth/register
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123",
  "username": "johndoe",
  "first_name": "John",
  "last_name": "Doe"
}
```

### Login

```bash
POST /api/v1/auth/login
Content-Type: application/json

{
  "email": "user@example.com",
  "password": "password123"
}
```

Response:
```json
{
  "success": true,
  "data": {
    "user": {
      "id": "uuid",
      "email": "user@example.com",
      "username": "johndoe"
    },
    "tokens": {
      "access_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refresh_token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "expires_in": 3600
    }
  }
}
```

### Using Tokens

Include the access token in the Authorization header:

```bash
curl -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
     http://localhost:3000/api/v1/users
```

## Resources

### Users

- `GET    /api/v1/users` - List all users
- `GET    /api/v1/users/:id` - Get user details
- `PATCH  /api/v1/users/:id` - Update user
- `DELETE /api/v1/users/:id` - Delete user
- `GET    /api/v1/users/:id/profile` - Get user profile
- `GET    /api/v1/users/:id/videos` - Get user's videos
- `GET    /api/v1/users/:id/posts` - Get user's posts
- `GET    /api/v1/users/:id/comments` - Get user's comments

### Videos

- `GET    /api/v1/videos` - List all videos
- `POST   /api/v1/videos` - Create a video
- `GET    /api/v1/videos/:id` - Get video details
- `PATCH  /api/v1/videos/:id` - Update video
- `DELETE /api/v1/videos/:id` - Delete video
- `POST   /api/v1/videos/:id/publish` - Publish video
- `POST   /api/v1/videos/:id/archive` - Archive video

### Posts

- `GET    /api/v1/posts` - List all posts
- `POST   /api/v1/posts` - Create a post
- `GET    /api/v1/posts/:id` - Get post details
- `PATCH  /api/v1/posts/:id` - Update post
- `DELETE /api/v1/posts/:id` - Delete post
- `POST   /api/v1/posts/:id/publish` - Publish post
- `POST   /api/v1/posts/:id/archive` - Archive post

### Comments

- `GET    /api/v1/videos/:video_id/comments` - List video comments
- `POST   /api/v1/videos/:video_id/comments` - Create video comment
- `GET    /api/v1/posts/:post_id/comments` - List post comments
- `POST   /api/v1/posts/:post_id/comments` - Create post comment
- `GET    /api/v1/comments/:id` - Get comment details
- `PATCH  /api/v1/comments/:id` - Update comment
- `DELETE /api/v1/comments/:id` - Delete comment
- `GET    /api/v1/comments/:id/comments` - Get replies
- `POST   /api/v1/comments/:id/comments` - Create reply

### Reactions

- `GET    /api/v1/videos/:video_id/reactions` - List video reactions
- `POST   /api/v1/videos/:video_id/reactions` - React to video
- `DELETE /api/v1/videos/:video_id/reactions/:id` - Remove reaction
- `GET    /api/v1/posts/:post_id/reactions` - List post reactions
- `POST   /api/v1/posts/:post_id/reactions` - React to post
- `DELETE /api/v1/posts/:post_id/reactions/:id` - Remove reaction
- `GET    /api/v1/comments/:comment_id/reactions` - List comment reactions
- `POST   /api/v1/comments/:comment_id/reactions` - React to comment
- `DELETE /api/v1/comments/:comment_id/reactions/:id` - Remove reaction

### Reports

- `GET    /api/v1/reports` - List all reports
- `POST   /api/v1/reports` - Create a report
- `GET    /api/v1/reports/:id` - Get report details
- `PATCH  /api/v1/reports/:id` - Update report
- `POST   /api/v1/reports/:id/review` - Mark as reviewing
- `POST   /api/v1/reports/:id/resolve` - Resolve report
- `POST   /api/v1/reports/:id/reject` - Reject report

## Pagination

All list endpoints support pagination:

```bash
GET /api/v1/videos?page=1&per_page=25
```

Parameters:
- `page` - Page number (default: 1)
- `per_page` - Items per page (default: 25, max: 100)
- `sort_by` - Sort field (default: created_at)
- `sort_order` - Sort order: asc or desc (default: desc)

Response includes pagination metadata:

```json
{
  "success": true,
  "data": [...],
  "meta": {
    "current_page": 1,
    "per_page": 25,
    "total_pages": 10,
    "total_count": 250,
    "has_next_page": true,
    "has_previous_page": false
  }
}
```

## Filtering

List endpoints support filtering:

```bash
GET /api/v1/videos?status=published&visibility=public
GET /api/v1/posts?tags[]=tech&tags[]=tutorial
GET /api/v1/comments?status=active
```

## Response Format

### Success Response

```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "title": "Example"
  },
  "meta": {}
}
```

### Error Response

```json
{
  "success": false,
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Validation failed",
    "details": {
      "email": ["has already been taken"]
    }
  }
}
```

## Status Codes

- `200 OK` - Success
- `201 Created` - Resource created
- `204 No Content` - Success with no response body
- `400 Bad Request` - Invalid request
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Insufficient permissions
- `404 Not Found` - Resource not found
- `422 Unprocessable Entity` - Validation error
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error

## Rate Limiting

API requests are limited to:
- **100 requests per minute** per IP address
- **1000 requests per hour** per authenticated user

Rate limit headers are included in responses:

```
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 95
X-RateLimit-Reset: 1640000000
```

## Versioning

See [versioning.md](./versioning.md) for detailed versioning strategy.

Current version: **v1**

## Interactive Documentation

Visit `/api-docs` for interactive Swagger UI documentation where you can test endpoints directly.

## Error Codes

| Code | Description |
|------|-------------|
| `VALIDATION_ERROR` | Request validation failed |
| `NOT_FOUND` | Resource not found |
| `UNAUTHORIZED` | Authentication required |
| `FORBIDDEN` | Insufficient permissions |
| `BAD_REQUEST` | Invalid request format |
| `RATE_LIMIT_EXCEEDED` | Too many requests |
| `INTERNAL_ERROR` | Server error |

## Examples

See the `/examples` directory for complete request/response examples in various programming languages:
- cURL
- JavaScript/TypeScript
- Python
- Ruby

## Support

- GitHub Issues: https://github.com/iamgerwin/rails_nextjs_commentable_project/issues
- Email: iamgerwin@live.com

## Changelog

See [CHANGELOG.md](./CHANGELOG.md) for version history and changes.
