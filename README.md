# Rails + Next.js Commentable Project

A production-ready monorepo starter template featuring Ruby on Rails 8.1.1 backend and Next.js 16.0.3 frontend with comprehensive CRUD operations, polymorphic comments, and modern development practices.

## 🏗️ Architecture

This project follows the Nx monorepo structure with clear separation of concerns:

```
rails_nextjs_commentable_project/
├── apps/
│   ├── api/          # Ruby on Rails 8.1.1 REST API
│   └── web/          # Next.js 16.0.3 Frontend
├── packages/
│   ├── shared-types/   # Shared TypeScript types
│   ├── shared-enums/   # Shared enums for consistency
│   └── shared-config/  # Shared configuration
├── docs/             # Documentation and diagrams
└── e2e/              # End-to-end tests with Playwright
```

## 🚀 Quick Start

### Prerequisites

- **Node.js**: >= 20.0.0
- **Ruby**: >= 3.3.0
- **Rails**: >= 8.1.1
- **PostgreSQL**: >= 14.0
- **Redis**: >= 7.0 (for caching and jobs)

### Installation

```bash
# Clone the repository
gh repo clone iamgerwin/rails_nextjs_commentable_project
cd rails_nextjs_commentable_project

# Install dependencies
npm install

# Set up the database
cd apps/api
bundle install
rails db:create db:migrate db:seed
cd ../..

# Start development servers
./run.sh dev
```

## 🛠️ Tech Stack

### Backend (Rails API)
- **Ruby on Rails** 8.1.1
- **PostgreSQL** for database
- **Redis** for caching and background jobs
- **Sidekiq** for job processing
- **JWT** for authentication
- **RSwag** for OpenAPI/Swagger documentation
- **RSpec** for testing

### Frontend (Next.js Web)
- **Next.js** 16.0.3 with App Router
- **TypeScript** for type safety
- **TailwindCSS** for styling
- **ShadCN UI** for components
- **React Query** for data fetching
- **Zod** for validation
- **next-intl** for i18n
- **Playwright** for e2e testing

### Shared Packages
- **@workspace/shared-types**: TypeScript interfaces and types
- **@workspace/shared-enums**: Centralized enums
- **@workspace/shared-config**: Environment variables and config

## 📊 Entity Relationship Diagram

See [docs/architecture/erd.md](docs/architecture/erd.md) for the complete ERD.

### Core Entities
- **User**: Authentication and authorization
- **Video**: Video content management
- **Post**: Blog posts and articles
- **Comment**: Polymorphic comments (commentable on Videos and Posts)
- **Reaction**: Like, dislike, love, clap reactions
- **Report**: Content reporting system

## 🎯 Features

### Core CRUD Operations
- ✅ User management with JWT authentication
- ✅ Video CRUD with metadata
- ✅ Post CRUD with rich content
- ✅ Polymorphic comments on Videos and Posts
- ✅ Reactions system (like, dislike, love, clap)
- ✅ Content reporting

### Design Patterns Implemented
- **Action Pattern**: All data mutations use action classes
- **Observer Pattern**: Audit trail for all entity changes
- **Strategy Pattern**: Dependency injection for services
- **Repository Pattern**: Data access abstraction
- **Service Objects**: Business logic separation

### Best Practices
- ✅ SOLID principles
- ✅ No N+1 queries (with eager loading)
- ✅ Caching strategy (Redis)
- ✅ Background job processing
- ✅ Comprehensive error handling
- ✅ API versioning
- ✅ Request rate limiting

### Compliance
- ✅ **i18n**: Internationalization ready
- ✅ **a11y**: WCAG 2.1 AA compliant
- ✅ **HIPAA**: Audit trails and encryption
- ✅ **ADA**: Accessible components
- ✅ **GDPR**: Data privacy and export

## 📚 Documentation

- [Architecture Overview](docs/architecture/overview.md)
- [Entity Relationship Diagram](docs/architecture/erd.md)
- [API Documentation](docs/api/README.md) (Swagger UI)
- [Frontend Components](docs/frontend/components.md)
- [Development Guide](docs/development/README.md)
- [Deployment Guide](docs/deployment/README.md)

## 🧪 Testing

```bash
# Run all tests
npm test

# Backend tests (RSpec)
cd apps/api && bundle exec rspec

# Frontend tests
nx test web

# E2E tests (Playwright)
npm run e2e
```

## 📜 Scripts

### Using run.sh

```bash
# Start all services in development
./run.sh dev

# Start only API
./run.sh api

# Start only web
./run.sh web

# Run tests
./run.sh test

# Build all apps
./run.sh build
```

## 🔐 Environment Variables

Copy `.env.example` to `.env` and configure:

```bash
# Database
DATABASE_URL=postgresql://localhost/rails_nextjs_dev

# Redis
REDIS_URL=redis://localhost:6379/0

# JWT
JWT_SECRET_KEY=your-secret-key

# API URLs
NEXT_PUBLIC_API_URL=http://localhost:3000
```

## 🚢 Deployment

See [docs/deployment/README.md](docs/deployment/README.md) for deployment instructions.

## 📝 License

MIT

## 👥 Contributors

- Gerwin (iamgerwin@live.com)

## 🤝 Contributing

Please read our [Contributing Guide](CONTRIBUTING.md) before submitting a Pull Request.
