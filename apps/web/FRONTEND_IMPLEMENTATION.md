# Frontend Implementation Guide

## Overview

This document tracks the implementation of the Next.js frontend application aligned with the Rails API backend.

## Technology Stack

- **Framework:** Next.js 15.2.4 (App Router)
  - Note: User requested 16.0.3, but latest stable is 15.x as of Nov 2025
- **React:** 19.0.0
- **TypeScript:** 5.7.2
- **Styling:** Tailwind CSS
- **UI Components:** ShadCN UI
- **State Management:** React Query (@tanstack/react-query)
- **Forms:** React Hook Form + Zod
- **HTTP Client:** Axios
- **Authentication:** Next-Auth (custom JWT implementation)
- **Monorepo:** Nx 20.8.2

## Shared Packages Integration

The frontend uses three shared packages for consistency:

### 1. @workspace/shared-enums
Contains all enum definitions matching backend:
- UserRole, UserStatus
- VideoStatus, VideoVisibility
- PostStatus, PostVisibility
- CommentStatus
- ReactionType
- ReportStatus, ReportReason
- etc.

### 2. @workspace/shared-types
Contains TypeScript interfaces matching backend responses:
- User, Video, Post, Comment
- Reaction, Report, AuditLog
- API Response types
- Pagination types
- Filter types

### 3. @workspace/shared-config
Contains configuration helpers:
- API configuration
- Environment variable helpers
- Feature flags

## Updated Types (Aligned with Backend)

### Changes Made:

1. **User Interface**
   - Added `fullName` and `initials` fields
   - Made `email` and `emailVerified` optional (only shown to owner/admin)

2. **Video Interface**
   - Changed `tags` and `metadata` from optional to required (empty arrays/objects)
   - Added `publishedAt` field

3. **Post Interface**
   - Added `readingTime` field
   - Changed `tags` and `metadata` from optional to required

4. **Reaction Interface**
   - Changed `type` to `typeName` to match backend
   - Removed `reactableType` and `reactableId` from create input (passed via URL)

5. **Report Interface**
   - Changed `reviewerId` to `moderatorId`
   - Changed `reviewer` to `moderator`
   - Added `resolvedAt` field
   - Changed `resolution` to `moderatorNotes`

6. **AuditLog Interface**
   - Changed `changes` to `changeData` to match backend column name

7. **ReportStatus Enum**
   - Changed `REVIEWING` to `UNDER_REVIEW` to match backend

## Project Structure

```
apps/web/
├── src/
│   ├── app/                    # Next.js App Router
│   │   ├── (auth)/            # Auth route group
│   │   │   ├── login/
│   │   │   ├── register/
│   │   │   └── layout.tsx
│   │   ├── (main)/            # Main app route group
│   │   │   ├── videos/
│   │   │   ├── posts/
│   │   │   ├── users/
│   │   │   └── layout.tsx
│   │   ├── admin/             # Admin routes
│   │   ├── api/               # API routes
│   │   ├── layout.tsx         # Root layout
│   │   ├── page.tsx           # Home page
│   │   └── global.css         # Global styles
│   ├── components/
│   │   ├── ui/                # ShadCN components
│   │   ├── auth/              # Authentication components
│   │   ├── videos/            # Video components
│   │   ├── posts/             # Post components
│   │   ├── comments/          # Comment components
│   │   ├── reactions/         # Reaction components
│   │   └── common/            # Shared components
│   ├── contexts/              # React contexts
│   │   └── auth-context.tsx   # Authentication context
│   ├── hooks/                 # Custom hooks
│   │   ├── use-auth.ts        # Authentication hook
│   │   ├── use-videos.ts      # Videos hook
│   │   ├── use-posts.ts       # Posts hook
│   │   └── use-comments.ts    # Comments hook
│   ├── services/              # API service layer
│   │   ├── auth.service.ts
│   │   ├── videos.service.ts
│   │   ├── posts.service.ts
│   │   ├── comments.service.ts
│   │   ├── reactions.service.ts
│   │   ├── reports.service.ts
│   │   └── users.service.ts
│   ├── lib/                   # Utilities
│   │   ├── api-client.ts      # ✅ Axios client with token refresh
│   │   └── utils.ts           # ✅ Tailwind class merger
│   └── types/                 # Local types (extend shared types)
├── public/                    # Static assets
├── components.json            # ✅ ShadCN configuration
├── tsconfig.json              # ✅ TypeScript config with path aliases
├── tailwind.config.ts         # Tailwind configuration
├── next.config.js             # Next.js configuration
└── project.json               # Nx project configuration
```

## Implementation Status

### ✅ Completed

1. **Project Setup**
   - Next.js app created with Nx
   - TypeScript configured with path aliases
   - Tailwind CSS configured
   - ShadCN UI configuration added

2. **Shared Packages**
   - Updated enums to match backend
   - Updated types to match backend API responses
   - All types properly exported

3. **API Client**
   - Axios client with automatic token management
   - Request/response interceptors
   - Automatic token refresh on 401
   - Query string builder for Ransack filters

### 🚧 In Progress

4. **Authentication System**
   - [ ] Auth context with JWT
   - [ ] Login page
   - [ ] Register page
   - [ ] Protected routes
   - [ ] Auth hooks

### 📋 Pending

5. **API Services**
   - [ ] Auth service (login, register, refresh)
   - [ ] Videos service (CRUD, publish, archive)
   - [ ] Posts service (CRUD, publish, archive)
   - [ ] Comments service (CRUD, nested replies)
   - [ ] Reactions service (create, delete, summary)
   - [ ] Reports service (create, moderation)
   - [ ] Users service (profile, stats)

6. **React Query Hooks**
   - [ ] useAuth hook
   - [ ] useVideos hook with Ransack filtering
   - [ ] usePosts hook with Ransack filtering
   - [ ] useComments hook
   - [ ] useReactions hook
   - [ ] useUsers hook

7. **UI Components**
   - [ ] ShadCN components (button, card, input, etc.)
   - [ ] Video card component
   - [ ] Post card component
   - [ ] Comment component with nested replies
   - [ ] Reaction buttons component
   - [ ] Filter/search components
   - [ ] Pagination component

8. **Pages - Public**
   - [ ] Home page
   - [ ] Videos list page with filters
   - [ ] Video detail page
   - [ ] Posts list page with filters
   - [ ] Post detail page (slug support)
   - [ ] User profile page

9. **Pages - Authentication**
   - [ ] Login page
   - [ ] Register page
   - [ ] Email verification page
   - [ ] Forgot password page
   - [ ] Reset password page

10. **Pages - User Dashboard**
    - [ ] My videos
    - [ ] My posts
    - [ ] My comments
    - [ ] Profile settings

11. **Pages - Admin**
    - [ ] User management
    - [ ] Reports dashboard
    - [ ] Audit logs viewer
    - [ ] Statistics dashboard

12. **Features**
    - [ ] Comments with nested replies
    - [ ] Reactions (like, love, clap, dislike)
    - [ ] Content reporting
    - [ ] Real-time view counting
    - [ ] Markdown editor for posts
    - [ ] Video player integration

13. **Testing**
    - [ ] Playwright E2E tests
    - [ ] Component tests
    - [ ] API integration tests

14. **Documentation**
    - [ ] Frontend architecture guide
    - [ ] Component documentation
    - [ ] API integration guide

## API Integration Notes

### Ransack Filtering

The API supports advanced filtering via Ransack. The `apiClient.buildQueryString()` method properly formats these queries:

```typescript
// Example: Filter videos
const filters = {
  q: {
    title_cont: 'tutorial',
    status_eq: 'published',
    visibility_eq: 'public',
    s: 'views_count desc'
  },
  page: 1,
  per_page: 25
};

const queryString = apiClient.buildQueryString(filters);
// Result: ?q[title_cont]=tutorial&q[status_eq]=published&q[visibility_eq]=public&q[s]=views_count desc&page=1&per_page=25
```

### Authentication Flow

1. **Login**
   - POST /api/v1/auth/login
   - Receive access_token and refresh_token
   - Store in localStorage

2. **Automatic Token Refresh**
   - On 401, automatically refresh using refresh_token
   - Update access_token
   - Retry failed request

3. **Logout**
   - DELETE /api/v1/auth/logout
   - Clear tokens from localStorage

### Error Handling

All API responses follow the format:
```typescript
{
  success: boolean;
  data?: T;
  error?: {
    message: string;
    code: string;
  };
  meta?: Record<string, unknown>;
}
```

## Next Steps

1. **Create Authentication System**
   - Auth context
   - Login/Register pages
   - Protected route wrapper

2. **Create API Services**
   - Implement service layer for each entity
   - Use React Query for caching

3. **Build UI Components**
   - Install essential ShadCN components
   - Create custom components

4. **Implement Core Features**
   - Video/Post listing and detail pages
   - Comments system
   - Reactions system

5. **Add Admin Features**
   - User management
   - Moderation dashboard
   - Analytics

## Environment Variables

Create `.env.local` in `apps/web/`:

```bash
NEXT_PUBLIC_API_URL=http://localhost:3000
NEXT_PUBLIC_API_VERSION=v1
```

## Known Issues / Discrepancies

1. **Next.js Version**
   - Requested: 16.0.3
   - Actual: 15.2.4
   - Reason: Version 16.x not yet released

2. **ShadCN Init**
   - Manual configuration required due to Nx monorepo structure
   - Components can be added with: `npx shadcn@latest add <component>`

## Development Commands

```bash
# Start development server
nx serve web

# Build for production
nx build web

# Run tests
nx test web

# Run E2E tests
nx e2e web-e2e

# Add ShadCN component
npx shadcn@latest add button -d apps/web
```

## References

- [Backend API Documentation](/apps/api/docs/API_DOCUMENTATION.md)
- [Ransack Guide](/apps/api/docs/RANSACK_GUIDE.md)
- [Shared Types](/packages/shared-types/src/index.ts)
- [Shared Enums](/packages/shared-enums/src/index.ts)
