# Ransack Filtering Guide

## Overview

Ransack is a powerful gem that provides advanced searching, filtering, and sorting capabilities for ActiveRecord models. This guide explains how to use Ransack with our API.

## Table of Contents

1. [Basic Concepts](#basic-concepts)
2. [Predicates](#predicates)
3. [Combining Conditions](#combining-conditions)
4. [Sorting](#sorting)
5. [Association Queries](#association-queries)
6. [Real-World Examples](#real-world-examples)
7. [Security Considerations](#security-considerations)

---

## Basic Concepts

Ransack queries are passed via the `q` query parameter. Each filter consists of:
- **Attribute name** - The field to filter on
- **Predicate** - The comparison operation
- **Value** - The value to compare against

### Syntax

```
?q[attribute_name_predicate]=value
```

### Example

```
GET /api/v1/videos?q[title_cont]=rails
```

This searches for videos where the title contains "rails".

---

## Predicates

### Equality Predicates

#### `eq` - Equals

Find exact matches.

```
GET /api/v1/videos?q[status_eq]=published
```

#### `not_eq` - Not equals

Exclude specific values.

```
GET /api/v1/videos?q[status_not_eq]=draft
```

### Text Predicates

#### `cont` - Contains

Case-insensitive substring search.

```
GET /api/v1/posts?q[title_cont]=tutorial
```

#### `cont_any` - Contains any

Match any of the provided values.

```
GET /api/v1/posts?q[title_cont_any][]=rails&q[title_cont_any][]=ruby
```

#### `cont_all` - Contains all

Match all provided values.

```
GET /api/v1/posts?q[content_cont_all][]=rails&q[content_cont_all][]=tutorial
```

#### `start` - Starts with

Match beginning of string.

```
GET /api/v1/users?q[username_start]=john
```

#### `end` - Ends with

Match end of string.

```
GET /api/v1/users?q[email_end]=@example.com
```

#### `i_cont` - Case-insensitive contains

Explicitly case-insensitive (default behavior for `cont`).

```
GET /api/v1/posts?q[title_i_cont]=RAILS
```

### Comparison Predicates

#### `gt` - Greater than

```
GET /api/v1/videos?q[views_count_gt]=1000
```

#### `gteq` - Greater than or equal

```
GET /api/v1/videos?q[views_count_gteq]=1000
```

#### `lt` - Less than

```
GET /api/v1/videos?q[duration_lt]=3600
```

#### `lteq` - Less than or equal

```
GET /api/v1/videos?q[duration_lteq]=3600
```

### Date/Time Predicates

#### Date range filtering

```
# Videos created after January 1, 2024
GET /api/v1/videos?q[created_at_gteq]=2024-01-01

# Videos created before December 31, 2024
GET /api/v1/videos?q[created_at_lteq]=2024-12-31

# Videos created in 2024
GET /api/v1/videos?q[created_at_gteq]=2024-01-01&q[created_at_lteq]=2024-12-31
```

#### Published in the last 7 days

```
GET /api/v1/posts?q[published_at_gteq]=<7-days-ago-timestamp>
```

### Array Predicates

#### `in` - In array

Match any value in the provided array.

```
GET /api/v1/videos?q[status_in][]=published&q[status_in][]=archived
```

#### `not_in` - Not in array

Exclude values in the array.

```
GET /api/v1/videos?q[status_not_in][]=draft&q[status_not_in][]=deleted
```

### Null Predicates

#### `null` - Is null

Find records with null values.

```
# Find top-level comments (no parent)
GET /api/v1/comments?q[parent_id_null]=true
```

#### `not_null` - Is not null

Find records with non-null values.

```
# Find nested replies (has parent)
GET /api/v1/comments?q[parent_id_not_null]=true

# Find published posts
GET /api/v1/posts?q[published_at_not_null]=true
```

### Boolean Predicates

#### `true` / `false`

```
# Find verified users
GET /api/v1/users?q[email_verified_true]=1

# Find unverified users
GET /api/v1/users?q[email_verified_false]=1
```

---

## Combining Conditions

### AND Conditions

Multiple conditions are combined with AND by default.

```
# Published videos that are public
GET /api/v1/videos?q[status_eq]=published&q[visibility_eq]=public
```

### OR Conditions

Use `_or_` to combine attributes with OR logic.

```
# Search in title OR content
GET /api/v1/posts?q[title_or_content_cont]=rails
```

### Complex Combinations

```
# (title contains "rails" OR content contains "rails")
# AND status is published
GET /api/v1/posts?q[title_or_content_cont]=rails&q[status_eq]=published
```

---

## Sorting

### Single Sort

Use the `s` parameter to sort results.

```
# Sort by creation date (descending)
GET /api/v1/videos?q[s]=created_at desc

# Sort by views (ascending)
GET /api/v1/videos?q[s]=views_count asc
```

**Note:** `asc` is optional; omitting it defaults to ascending.

### Multiple Sorts

Apply multiple sort criteria.

```
# Sort by status, then by views (descending)
GET /api/v1/videos?q[s][]=status asc&q[s][]=views_count desc
```

### Common Sort Fields

**Videos:**
- `created_at` - Creation date
- `published_at` - Publish date
- `views_count` - View count
- `comments_count` - Comment count
- `reactions_count` - Reaction count
- `title` - Alphabetical

**Posts:**
- `created_at` - Creation date
- `published_at` - Publish date
- `views_count` - View count
- `reading_time` - Reading time

**Users:**
- `created_at` - Registration date
- `username` - Alphabetical
- `role` - Role

**Comments:**
- `created_at` - Comment date
- `reactions_count` - Reactions

---

## Association Queries

Ransack allows filtering through associations using the association name.

### Filter by User Attributes

```
# Find videos by username
GET /api/v1/videos?q[user_username_eq]=johndoe

# Find videos by users whose username contains "john"
GET /api/v1/videos?q[user_username_cont]=john

# Find posts by user email
GET /api/v1/posts?q[user_email_eq]=user@example.com
```

### Filter by Commentable

```
# Find comments on videos only
GET /api/v1/comments?q[commentable_type_eq]=Video

# Find comments on posts only
GET /api/v1/comments?q[commentable_type_eq]=Post
```

### Filter by Reactable

```
# Find reactions on videos
GET /api/v1/reactions?q[reactable_type_eq]=Video

# Find reactions by specific users
GET /api/v1/reactions?q[user_username_cont]=john
```

### Filter Reports

```
# Find reports about comments
GET /api/v1/reports?q[reportable_type_eq]=Comment

# Find reports by specific reporter
GET /api/v1/reports?q[reporter_username_eq]=johndoe

# Find reports reviewed by specific moderator
GET /api/v1/admin/reports?q[moderator_username_eq]=mod123
```

---

## Real-World Examples

### Example 1: Popular Recent Videos

Find published, public videos created in the last 30 days with at least 100 views, sorted by views.

```
GET /api/v1/videos?q[status_eq]=published&q[visibility_eq]=public&q[created_at_gteq]=<30-days-ago>&q[views_count_gteq]=100&q[s]=views_count desc
```

### Example 2: User's Published Content

Find all published posts by a specific user.

```
GET /api/v1/posts?q[user_username_eq]=johndoe&q[status_eq]=published&q[s]=published_at desc
```

### Example 3: Trending Content

Find videos and posts with high engagement (many reactions and comments).

```
# Videos
GET /api/v1/videos?q[reactions_count_gteq]=50&q[comments_count_gteq]=10&q[s]=views_count desc

# Posts
GET /api/v1/posts?q[reactions_count_gteq]=50&q[comments_count_gteq]=10&q[s]=views_count desc
```

### Example 4: Moderation Queue

Find pending reports on comments created today.

```
GET /api/v1/admin/reports?q[status_eq]=pending&q[reportable_type_eq]=Comment&q[created_at_gteq]=<today>&q[s]=created_at desc
```

### Example 5: User Activity

Find all comments by a user on videos.

```
GET /api/v1/comments?q[user_username_eq]=johndoe&q[commentable_type_eq]=Video&q[s]=created_at desc
```

### Example 6: Content Discovery

Find tutorial posts with "rails" in title or content, published in the last 90 days.

```
GET /api/v1/posts?q[title_or_content_cont]=rails&q[tags_cont]=tutorial&q[published_at_gteq]=<90-days-ago>&q[s]=views_count desc
```

### Example 7: Spam Detection

Find comments flagged as spam.

```
GET /api/v1/admin/comments?q[status_eq]=flagged&q[created_at_gteq]=<today>
```

### Example 8: User Engagement

Find users who joined in the last month and have created at least one video or post.

```
# This requires custom scope - see admin statistics endpoint
GET /api/v1/admin/statistics/users?days=30
```

### Example 9: Content by Tag

Find all videos tagged with "tutorial" AND "rails".

```
GET /api/v1/videos?q[tags_cont_all][]=tutorial&q[tags_cont_all][]=rails
```

### Example 10: Inactive Content

Find draft videos that haven't been updated in 30 days.

```
GET /api/v1/videos?q[status_eq]=draft&q[updated_at_lteq]=<30-days-ago>&q[s]=updated_at asc
```

---

## Security Considerations

### Whitelisted Attributes

Only specific attributes are searchable via Ransack for security. Sensitive fields like `password_digest`, `email_verification_token`, and `password_reset_token` are excluded.

**Searchable attributes are defined in:**
- `config/initializers/ransack.rb`
- Each model's `ransackable_attributes` method

### Whitelisted Associations

Only defined associations can be searched through. This prevents unauthorized data access.

**Searchable associations are defined in:**
- Each model's `ransackable_associations` method

### Example: User Model

```ruby
def self.ransackable_attributes(auth_object = nil)
  # Password fields are excluded
  column_names - %w[password_digest email_verification_token password_reset_token]
end

def self.ransackable_associations(auth_object = nil)
  %w[videos posts comments reactions]
end
```

### Rate Limiting

Ransack queries can be resource-intensive. The API implements rate limiting:
- **Authenticated users:** 100 requests/minute
- **Unauthenticated users:** 30 requests/minute

### Performance Tips

1. **Use specific predicates** - `eq` is faster than `cont`
2. **Limit results** - Always use pagination
3. **Index frequently searched fields** - Database indexes speed up queries
4. **Avoid wildcard searches** - `cont` can be slow on large datasets
5. **Use `distinct: true`** - Prevents duplicate results in association queries

---

## Advanced Usage

### Grouping with Ransack

While Ransack doesn't directly support grouping, you can use the `summary=true` parameter on reactions endpoints for grouped results.

```
GET /api/v1/videos/:id/reactions?summary=true
```

**Response:**
```json
{
  "summary": {
    "like": 100,
    "love": 50,
    "clap": 25
  },
  "total": 175
}
```

### Custom Scopes

Some endpoints provide custom scopes for complex queries:

```
# Top-level comments only
GET /api/v1/comments?q[parent_id_null]=true

# Deleted users (admin only)
GET /api/v1/admin/users?q[deleted_at_not_null]=true
```

---

## Troubleshooting

### Common Issues

#### 1. No Results Found

**Problem:** Query returns empty array.

**Solutions:**
- Check predicate syntax
- Verify attribute names (use snake_case)
- Ensure values are properly encoded
- Check authorization scopes

#### 2. Unexpected Results

**Problem:** Results don't match expectations.

**Solutions:**
- Review AND/OR logic
- Check data types (numbers vs strings)
- Verify date formats (ISO 8601)
- Use `distinct: true` for association queries

#### 3. Slow Queries

**Problem:** Requests timeout or are very slow.

**Solutions:**
- Add pagination (`page` and `per_page`)
- Use more specific predicates
- Limit searched fields
- Check database indexes

---

## Testing Ransack Queries

### Using cURL

```bash
# Basic search
curl "http://localhost:3000/api/v1/videos?q[title_cont]=rails"

# Multiple filters
curl "http://localhost:3000/api/v1/videos?q[status_eq]=published&q[visibility_eq]=public"

# With authentication
curl -H "Authorization: Bearer <token>" \
  "http://localhost:3000/api/v1/videos?q[title_cont]=rails"
```

### Using JavaScript (Fetch API)

```javascript
const params = new URLSearchParams({
  'q[title_cont]': 'rails',
  'q[status_eq]': 'published',
  'q[s]': 'views_count desc',
  'page': 1,
  'per_page': 25
});

fetch(`/api/v1/videos?${params}`, {
  headers: {
    'Authorization': `Bearer ${token}`
  }
})
  .then(res => res.json())
  .then(data => console.log(data));
```

### Using TypeScript (with React Query)

```typescript
import { useQuery } from '@tanstack/react-query';

interface VideoFilters {
  title?: string;
  status?: string;
  visibility?: string;
  sort?: string;
}

function useVideos(filters: VideoFilters, page = 1) {
  const params = new URLSearchParams();

  if (filters.title) params.set('q[title_cont]', filters.title);
  if (filters.status) params.set('q[status_eq]', filters.status);
  if (filters.visibility) params.set('q[visibility_eq]', filters.visibility);
  if (filters.sort) params.set('q[s]', filters.sort);

  params.set('page', page.toString());
  params.set('per_page', '25');

  return useQuery({
    queryKey: ['videos', filters, page],
    queryFn: () =>
      fetch(`/api/v1/videos?${params}`, {
        headers: {
          'Authorization': `Bearer ${token}`
        }
      }).then(res => res.json())
  });
}
```

---

## Additional Resources

- [Ransack GitHub Repository](https://github.com/activerecord-hackery/ransack)
- [Ransack Documentation](https://activerecord-hackery.github.io/ransack/)
- [API Documentation](./API_DOCUMENTATION.md)

---

## Summary

Ransack provides a powerful, flexible way to filter and sort API results. Key takeaways:

1. Use predicates to specify comparison operations
2. Combine multiple filters with AND logic by default
3. Use `_or_` for OR logic between attributes
4. Sort with `q[s]=field direction`
5. Filter through associations using association names
6. Always paginate results for performance
7. Only whitelisted attributes are searchable (security)

For questions or issues, please report at: https://github.com/anthropics/claude-code/issues
