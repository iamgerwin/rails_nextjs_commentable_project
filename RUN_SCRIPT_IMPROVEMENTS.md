# run.sh Script Improvements

## Overview

The `run.sh` script has been updated to perfectly align with the current project setup, making it easier to develop and manage the Rails + Next.js monorepo.

## ✅ Changes Made

### 1. **Updated Prerequisites Check**

**Before:**
- Required PostgreSQL and Redis
- Failed if not available

**After:**
- ✅ Only requires Node.js, Ruby, and Bundler
- ⚠️ PostgreSQL and Redis are now optional
- Shows warnings instead of errors for optional dependencies
- Works perfectly with SQLite for development

### 2. **Improved Service Checks**

**Before:**
- Required PostgreSQL and Redis to be running
- Failed if services weren't available

**After:**
- ✅ Checks services but doesn't fail if missing
- ✅ Informs user: "Development will use SQLite (no PostgreSQL needed)"
- ✅ Informs user: "Background jobs disabled (no Redis needed)"
- ✅ Only starts Sidekiq if Redis is actually running

### 3. **Fixed Next.js Start Command**

**Before:**
```bash
cd apps/web && npm run dev -- -p 4200
```

**After:**
```bash
npx nx serve web
```

- ✅ Uses Nx properly
- ✅ Respects Nx configuration
- ✅ Better error handling

### 4. **Auto-Create Environment File**

**New Feature:**
- ✅ Automatically creates `apps/web/.env.local` if missing
- ✅ Sets default values:
  ```bash
  NEXT_PUBLIC_API_URL=http://localhost:3000
  NEXT_PUBLIC_API_VERSION=v1
  ```

### 5. **Enhanced tmux Support**

**Before:**
- Basic tmux session
- All windows unnamed

**After:**
- ✅ Kills existing session before starting (prevents conflicts)
- ✅ Named windows:
  - Window 0: "Rails API"
  - Window 1: "Next.js Web"
  - Window 2: "Sidekiq" (only if Redis available)
- ✅ Better user instructions
- ✅ Helpful tmux command reference in help

### 6. **Improved Database Setup**

**Before:**
- Used `db:exists` which may not work

**After:**
- ✅ Uses `db:version` for checking
- ✅ Better error handling
- ✅ Clear messages about SQLite usage

### 7. **Enhanced Help Documentation**

**Additions:**
- ✅ Sample user credentials
- ✅ Development stack details
- ✅ Comprehensive tmux commands
- ✅ Troubleshooting section
- ✅ Tips for common tasks
- ✅ Better formatting with Unicode borders

### 8. **Background Process Management**

**Improvements:**
- ✅ Better cleanup with trap
- ✅ Conditional Sidekiq start (only if Redis available)
- ✅ Clear service URLs printed
- ✅ PID tracking for all processes

## Usage

### Quick Start

```bash
# First time setup
./run.sh install          # Install all dependencies
./run.sh setup --seed     # Setup database with sample data

# Start development
./run.sh dev              # Starts all services with tmux
```

### Individual Services

```bash
./run.sh api              # Rails API only
./run.sh web              # Next.js only
```

### Database Management

```bash
./run.sh setup            # Create and migrate database
./run.sh setup --seed     # Also add sample data
```

### Testing

```bash
./run.sh test             # Run all tests
./run.sh lint             # Run linters
./run.sh e2e              # Run E2E tests
```

### Health Check

```bash
./run.sh check            # Verify prerequisites
```

## Sample Users (After Seeding)

The script now clearly documents the sample users:

| Role      | Email                   | Password              |
|-----------|-------------------------|-----------------------|
| Admin     | admin@example.com       | admin@example.com     |
| Moderator | moderator@example.com   | moderator@example.com |
| User      | user@example.com        | user@example.com      |

## Service URLs

| Service          | URL                              |
|------------------|----------------------------------|
| Rails API        | http://localhost:3000            |
| Next.js Frontend | http://localhost:4200            |
| API Docs         | http://localhost:3000/api-docs   |

## tmux Workflow

When using tmux (recommended):

```bash
# Start all services
./run.sh dev

# In tmux session:
Ctrl+b then 0    # Switch to Rails API window
Ctrl+b then 1    # Switch to Next.js window
Ctrl+b then 2    # Switch to Sidekiq window (if available)
Ctrl+b then d    # Detach from session (services keep running)

# Later, reattach:
tmux attach -t rails_nextjs_app

# Stop everything:
tmux kill-session -t rails_nextjs_app
```

## Troubleshooting

The help now includes common issues:

### Port Already in Use

```bash
# Kill process on port 3000
lsof -ti:3000 | xargs kill -9

# Kill process on port 4200
lsof -ti:4200 | xargs kill -9
```

### Database Issues

```bash
# Reset database
cd apps/api
bundle exec rails db:reset
bundle exec rails db:seed
```

### Frontend Not Loading

```bash
# Check environment file exists
ls apps/web/.env.local

# If missing, create it:
cat > apps/web/.env.local << EOF
NEXT_PUBLIC_API_URL=http://localhost:3000
NEXT_PUBLIC_API_VERSION=v1
EOF
```

### Clean Build

```bash
# Full clean rebuild
rm -rf node_modules apps/web/.next
npm install
```

## Benefits

### For Development

1. **Zero Configuration** - Works out of the box with SQLite
2. **Optional Services** - PostgreSQL and Redis not required
3. **Auto Environment** - Creates .env.local automatically
4. **Better UX** - Clear messages and helpful tips

### For Production

1. **Service Detection** - Automatically uses PostgreSQL/Redis if available
2. **Flexible Deployment** - Works with or without tmux
3. **Process Management** - Proper cleanup and signal handling

### For Team

1. **Clear Documentation** - Comprehensive help text
2. **Sample Data** - Easy to get started with seeded users
3. **Troubleshooting** - Common issues documented
4. **Standards** - Consistent development workflow

## Comparison

### Before

```bash
./run.sh dev
# ✗ Error: PostgreSQL not running
# ✗ Error: Redis not running
# Script exits
```

### After

```bash
./run.sh dev
# ⚠ PostgreSQL not found (optional for production)
# ⚠ Redis not found (optional, needed for Sidekiq)
# ℹ Development will use SQLite (no PostgreSQL needed)
# ℹ Background jobs disabled (no Redis needed)
# ✓ All required prerequisites met
# ✓ Starting all services...
# ✓ Created apps/web/.env.local
# ✓ All services started in tmux session 'rails_nextjs_app'
```

## Development Workflow

### Typical Daily Workflow

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

### First Time Setup

```bash
# 1. Clone repository
git clone <repo>
cd rails_nextjs_commentable_project

# 2. Install dependencies
./run.sh install

# 3. Setup database with sample data
./run.sh setup --seed

# 4. Start development
./run.sh dev

# 5. Open browser
# - Frontend: http://localhost:4200
# - API: http://localhost:3000
# - API Docs: http://localhost:3000/api-docs

# 6. Login with sample user
# Email: user@example.com
# Password: user@example.com
```

## Conclusion

The improved `run.sh` script now:

✅ Works perfectly with the current project setup
✅ Doesn't require PostgreSQL or Redis for development
✅ Automatically configures environment variables
✅ Provides comprehensive help and documentation
✅ Supports both tmux and simple background processes
✅ Includes troubleshooting guidance
✅ Makes onboarding new developers easier

The script is production-ready and developer-friendly!
