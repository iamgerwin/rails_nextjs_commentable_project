# Rails + Next.js Commentable Project

[![CI](https://github.com/iamgerwin/rails_nextjs_commentable_project/workflows/CI/badge.svg)](https://github.com/iamgerwin/rails_nextjs_commentable_project/actions/workflows/ci.yml)
[![CD](https://github.com/iamgerwin/rails_nextjs_commentable_project/workflows/CD/badge.svg)](https://github.com/iamgerwin/rails_nextjs_commentable_project/actions/workflows/cd.yml)
[![Code Quality](https://github.com/iamgerwin/rails_nextjs_commentable_project/workflows/Code%20Quality/badge.svg)](https://github.com/iamgerwin/rails_nextjs_commentable_project/actions/workflows/code-quality.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

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

#### Required
- **Node.js**: >= 20.0.0
- **Ruby**: >= 3.3.6
- **Bundler**: Latest version

#### Optional (For Production)
- **PostgreSQL**: >= 14.0 (Development uses SQLite by default)
- **Redis**: >= 7.0 (For Sidekiq background jobs)
- **tmux**: For better process management (recommended)

> **Note**: The project works out of the box with SQLite for development. PostgreSQL and Redis are only needed for production deployments.

### Installation

```bash
# Clone the repository
gh repo clone iamgerwin/rails_nextjs_commentable_project
cd rails_nextjs_commentable_project

# Install all dependencies (Node.js + Ruby)
./run.sh install

# Setup database with sample data
./run.sh setup --seed

# Start all development servers
./run.sh dev
```

### First Time Setup

After installation, you can login with these sample users:

| Role      | Email                   | Password              |
|-----------|-------------------------|-----------------------|
| Admin     | admin@example.com       | admin@example.com     |
| Moderator | moderator@example.com   | moderator@example.com |
| User      | user@example.com        | user@example.com      |

### Access Points

| Service          | URL                              |
|------------------|----------------------------------|
| Rails API        | http://localhost:3000            |
| Next.js Frontend | http://localhost:4200            |
| API Docs         | http://localhost:3000/api-docs   |

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
- [CI/CD with GitHub Actions](docs/ci-cd/github-actions.md)

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

## 📜 Development Scripts

The `run.sh` script provides a unified interface for all development tasks. It automatically handles prerequisites, environment setup, and process management.

### Available Commands

```bash
./run.sh [command] [options]
```

#### Development Commands

**`./run.sh dev`** - Start all services in development mode
- Automatically creates `apps/web/.env.local` if missing
- Starts Rails API on port 3000
- Starts Next.js frontend on port 4200
- Starts Sidekiq (if Redis is available)
- Uses tmux for better process management (if installed)

```bash
# Start all services with tmux
./run.sh dev

# In tmux session:
# Ctrl+b then 0    - Switch to Rails API window
# Ctrl+b then 1    - Switch to Next.js window
# Ctrl+b then 2    - Switch to Sidekiq window (if available)
# Ctrl+b then d    - Detach from session (services keep running)

# Later, reattach:
tmux attach -t rails_nextjs_app

# Stop everything:
tmux kill-session -t rails_nextjs_app
```

**`./run.sh api`** - Start only the Rails API server
```bash
./run.sh api
# Runs on http://localhost:3000
```

**`./run.sh web`** - Start only the Next.js frontend
```bash
./run.sh web
# Runs on http://localhost:4200
```

#### Setup Commands

**`./run.sh install`** - Install all dependencies
```bash
./run.sh install
# Installs both Node.js and Ruby dependencies
```

**`./run.sh setup`** - Setup database (create and migrate)
```bash
./run.sh setup
# Creates database and runs migrations
```

**`./run.sh setup --seed`** - Setup database with sample data
```bash
./run.sh setup --seed
# Creates database, runs migrations, and seeds sample users
```

#### Testing Commands

**`./run.sh test`** - Run all tests (Rails RSpec + Next.js)
```bash
./run.sh test
```

**`./run.sh lint`** - Run linters on all code
```bash
./run.sh lint
```

**`./run.sh e2e`** - Run end-to-end tests with Playwright
```bash
./run.sh e2e
```

#### Build Commands

**`./run.sh build`** - Build all applications for production
```bash
./run.sh build
```

#### Utility Commands

**`./run.sh check`** - Check prerequisites and services
```bash
./run.sh check
# Verifies Node.js, Ruby, Bundler are installed
# Checks if PostgreSQL and Redis are available
```

**`./run.sh help`** - Show comprehensive help message
```bash
./run.sh help
```

### Troubleshooting

#### Port Already in Use

```bash
# Kill process on port 3000 (Rails API)
lsof -ti:3000 | xargs kill -9

# Kill process on port 4200 (Next.js)
lsof -ti:4200 | xargs kill -9
```

#### Database Issues

```bash
# Reset database
cd apps/api
bundle exec rails db:reset
bundle exec rails db:seed
cd ../..
```

#### Frontend Not Loading

```bash
# Check environment file exists
ls apps/web/.env.local

# If missing, the run.sh script will create it automatically
# Or create it manually:
cat > apps/web/.env.local << EOF
NEXT_PUBLIC_API_URL=http://localhost:3000
NEXT_PUBLIC_API_VERSION=v1
EOF
```

#### Clean Build

```bash
# Full clean rebuild
rm -rf node_modules apps/web/.next
npm install
```

### Daily Development Workflow

```bash
# 1. Start development environment
./run.sh dev

# 2. Work in your editor
# Services are running in tmux

# 3. Check logs if needed
tail -f apps/api/log/development.log

# 4. Detach from tmux to work
Ctrl+b then d

# 5. Reattach when needed
tmux attach -t rails_nextjs_app

# 6. Stop everything when done
tmux kill-session -t rails_nextjs_app
```

### Manual NPM/Yarn Commands

If you prefer manual control:

```bash
# Backend (Rails API)
cd apps/api
bundle exec rails server -p 3000

# Frontend (Next.js)
npx nx serve web

# Sidekiq (if Redis is running)
cd apps/api
bundle exec sidekiq
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

## 🔄 CI/CD

This project uses GitHub Actions for continuous integration and deployment:

### Automated Workflows

- **CI (Continuous Integration)** - Runs on every push and PR
  - Linting and type checking
  - Backend tests (RSpec)
  - Frontend tests (Jest)
  - E2E tests (Playwright)
  - Security scanning
  - Build verification

- **CD (Continuous Deployment)** - Automated deployments
  - Staging: Deploys on push to `develop`
  - Production: Deploys on push to `main`
  - Automatic database migrations
  - Health checks and smoke tests
  - Rollback on failure

- **Code Quality** - Enforces code standards
  - ESLint, Prettier, TypeScript
  - RuboCop, Reek, Rails Best Practices
  - Brakeman security scanner
  - Conventional commits validation

- **Dependency Updates** - Weekly automated updates
  - Node.js packages (Mondays at 9 AM UTC)
  - Ruby gems (Mondays at 9 AM UTC)
  - Security audits
  - Auto-creates PRs

- **Production Health Check** - Monitors production (every 30 minutes)
  - API health endpoint
  - Frontend availability
  - Database connectivity
  - Redis connectivity
  - Performance metrics
  - Uptime tracking

- **Release** - Automated releases
  - Version tagging (`v*.*.*`)
  - Changelog generation
  - Docker image builds
  - Multi-platform artifacts
  - GitHub releases

### Setup

See [CI/CD Documentation](docs/ci-cd/github-actions.md) for detailed setup instructions.

**Required Secrets**:
```bash
RAILS_MASTER_KEY          # Rails credentials
VERCEL_TOKEN              # Vercel deployment (optional)
DOCKER_USERNAME           # Docker Hub username
DOCKER_PASSWORD           # Docker Hub password
NEXT_PUBLIC_API_URL       # Production API URL
SLACK_WEBHOOK_URL         # Slack notifications (optional)
```

**Branch Protection** (recommended):
- Require status checks: CI Success, Lint & Format, Tests
- Require pull request reviews (at least 1)
- Require conversation resolution

## 📝 License

MIT

## 👥 Contributors

- Gerwin (iamgerwin@live.com)

## 🤝 Contributing

Please read our [Contributing Guide](CONTRIBUTING.md) before submitting a Pull Request.
