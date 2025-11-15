# Rails API

Production-ready Rails 8.1.1 REST API with comprehensive CRUD operations, polymorphic associations, and modern design patterns.

## Architecture

This API follows a well-structured architecture with clear separation of concerns:

```
app/
├── actions/          # Action pattern for data mutations
├── controllers/      # API endpoints
├── models/           # ActiveRecord models
├── observers/        # Observer pattern for audit trails
├── serializers/      # JSON serialization
├── services/         # Business logic
├── strategies/       # Strategy pattern for dependency injection
└── validators/       # Custom validations
```

## Design Patterns

### Action Pattern

All data mutations use dedicated action classes for:
- Clear separation of concerns
- Easy testing
- Reusable business logic
- Consistent error handling

Example:
```ruby
Videos::CreateAction.call(user: current_user, params: video_params)
```

### Observer Pattern

Observers automatically track changes for audit trails:
```ruby
class VideoObserver < ApplicationObserver
  def after_create(video)
    AuditLog.create(...)
  end
end
```

### Strategy Pattern

Strategies provide flexible implementations with dependency injection:
```ruby
class CacheStrategy
  def self.for(type)
    case type
    when :redis then RedisCacheStrategy.new
    when :memory then MemoryCacheStrategy.new
    end
  end
end
```

## Database Schema

The database uses PostgreSQL with the following core entities:
- Users (with soft delete)
- Videos (with soft delete)
- Posts (with soft delete)
- Comments (polymorphic, with soft delete)
- Reactions (polymorphic)
- Reports (polymorphic)
- AuditLogs (immutable)

See `/docs/architecture/erd.md` for the complete ERD.

## Authentication

JWT-based authentication with:
- Access tokens (1 hour expiry)
- Refresh tokens (7 days expiry)
- Secure password hashing with bcrypt
- Email verification support

## API Versioning

All endpoints are versioned under `/api/v1/`:
```
POST   /api/v1/auth/register
POST   /api/v1/auth/login
GET    /api/v1/videos
POST   /api/v1/videos/:id/comments
```

## Pagination

All list endpoints support pagination:
```
GET /api/v1/videos?page=1&per_page=25&sort_by=created_at&sort_order=desc
```

Response includes metadata:
```json
{
  "data": [...],
  "meta": {
    "current_page": 1,
    "per_page": 25,
    "total_pages": 10,
    "total_count": 250
  }
}
```

## Rate Limiting

Rate limiting via rack-attack:
- 100 requests per minute per IP
- Configurable via environment variables
- Custom limits for specific endpoints

## Caching

Multi-level caching strategy:
- Redis for session and application cache
- HTTP cache headers
- Fragment caching for expensive queries
- Counter caches to avoid N+1 queries

## Background Jobs

Sidekiq for asynchronous processing:
- Email delivery
- Video processing
- Notification delivery
- Report processing

## Error Handling

Consistent error responses:
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

## Testing

Comprehensive test suite with RSpec:
```bash
bundle exec rspec
```

Test coverage:
- Model specs with Factory Bot
- Request specs for all endpoints
- Service specs for business logic
- Action specs for mutations

## Security

- SQL injection prevention (ActiveRecord)
- XSS protection
- CSRF protection
- Rate limiting
- Secure headers
- Input validation
- Audit logging (HIPAA compliant)

## Setup

1. Install dependencies:
```bash
bundle install
```

2. Create database:
```bash
rails db:create
rails db:migrate
rails db:seed
```

3. Start server:
```bash
rails server -p 3000
```

4. Start Sidekiq:
```bash
bundle exec sidekiq
```

## API Documentation

Interactive API documentation available at:
- Swagger UI: `http://localhost:3000/api-docs`
- OpenAPI JSON: `http://localhost:3000/api-docs/v1/swagger.json`

## Environment Variables

See `/.env.example` in the root directory.

## Code Quality

Run linters and security checks:
```bash
bundle exec rubocop
bundle exec brakeman
bundle exec bundle-audit
```

## Monitoring

- Lograge for structured logging
- Sentry for error tracking
- Bullet for N+1 query detection (development)

## Performance

- Database indexes on all foreign keys
- Eager loading to prevent N+1 queries
- Counter caches for associations
- Redis caching for frequently accessed data
- Background job processing for heavy tasks
