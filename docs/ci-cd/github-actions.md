# GitHub Actions CI/CD

This document describes the GitHub Actions workflows configured for this project.

## Overview

The project uses GitHub Actions for continuous integration, continuous deployment, code quality checks, and automated maintenance tasks.

## Workflows

### 1. CI (Continuous Integration)

**File**: `.github/workflows/ci.yml`

**Triggers**:
- Push to `main` or `develop` branches
- Pull requests to `main` or `develop` branches

**Jobs**:

1. **Lint & Format** - Code linting and formatting checks
   - ESLint for JavaScript/TypeScript
   - TypeScript type checking
   - Runs in parallel for all packages

2. **Backend Tests (Rails)** - Rails RSpec test suite
   - PostgreSQL 16 service
   - Redis 7 service
   - RSpec with documentation format
   - Coverage reports uploaded as artifacts

3. **Frontend Tests (Next.js)** - Next.js Jest test suite
   - Jest with coverage
   - Coverage reports uploaded as artifacts

4. **Build Check** - Verify all packages build successfully
   - Builds all Nx targets
   - Validates Next.js build output

5. **E2E Tests (Playwright)** - End-to-end tests
   - Starts Rails API server
   - Runs Playwright tests against real backend
   - Screenshots and videos on failure

6. **Security Scan** - Security vulnerability scanning
   - npm audit for Node.js packages
   - Bundler audit for Ruby gems
   - Brakeman for Rails security issues

7. **Database Schema Check** - Validates schema consistency
   - Runs migrations
   - Checks schema.rb is up to date

**Artifacts**:
- Backend coverage reports (7 days retention)
- Frontend coverage reports (7 days retention)
- Playwright reports and videos (7 days retention)
- Brakeman security reports (7 days retention)

**Required Secrets**:
- `RAILS_MASTER_KEY` - Rails credentials master key

### 2. CD (Continuous Deployment)

**File**: `.github/workflows/cd.yml`

**Triggers**:
- Push to `main` branch (production)
- Push to `develop` branch (staging)
- Version tags (`v*`)
- Manual workflow dispatch

**Jobs**:

1. **Build and Test** - Pre-deployment validation
   - Runs all linters
   - Builds all packages
   - Uploads build artifacts

2. **Deploy to Staging**
   - Triggered on `develop` branch
   - Downloads build artifacts
   - Deploys to staging environment
   - Runs database migrations
   - Sends deployment notifications

3. **Deploy to Production**
   - Triggered on `main` branch or version tags
   - Creates deployment backup
   - Deploys Rails API
   - Deploys Next.js frontend
   - Runs database migrations
   - Performs health checks
   - Creates GitHub release (for tags)
   - Rollback on failure

4. **Smoke Tests** - Post-deployment validation
   - API health checks
   - Frontend health checks
   - Database connectivity tests
   - Redis connectivity tests
   - Critical feature tests

**Environments**:
- `staging` - Staging environment (develop branch)
- `production` - Production environment (main branch)

**Required Secrets**:
- `RAILS_MASTER_KEY` - Rails credentials
- `VERCEL_TOKEN` - Vercel deployment token (if using Vercel)
- `NEXT_PUBLIC_API_URL` - Production API URL
- `SLACK_WEBHOOK_URL` - Slack notifications (optional)

### 3. Code Quality

**File**: `.github/workflows/code-quality.yml`

**Triggers**:
- Pull requests to `main` or `develop`
- Push to `main` or `develop`

**Jobs**:

1. **Frontend Code Quality**
   - ESLint with annotations
   - Prettier format check
   - TypeScript type check
   - Console.log detection
   - TODO comment detection

2. **Backend Code Quality**
   - RuboCop (Ruby style guide)
   - Reek (code smell detection)
   - Rails Best Practices
   - Brakeman security scanner
   - Debug statement detection

3. **Shared Packages Quality**
   - Lint all shared packages
   - Type check all shared packages

4. **Documentation Quality**
   - Markdown link checking
   - Documentation completeness check

5. **Commit Message Quality**
   - Conventional commits validation
   - Commit message format checking

6. **Code Coverage Check**
   - Coverage threshold validation
   - PR coverage comments

**Artifacts**:
- RuboCop reports (7 days retention)
- Reek reports (7 days retention)
- Rails Best Practices reports (7 days retention)
- Brakeman reports (7 days retention)

### 4. Dependency Updates

**File**: `.github/workflows/dependency-updates.yml`

**Triggers**:
- Scheduled: Every Monday at 9:00 AM UTC
- Manual workflow dispatch

**Jobs**:

1. **Update Node.js Dependencies**
   - Uses npm-check-updates
   - Updates package.json
   - Runs tests
   - Creates PR with changes

2. **Update Ruby Dependencies**
   - Uses bundle update
   - Updates Gemfile.lock
   - Runs RSpec tests
   - Creates PR with changes

3. **Security Audit**
   - npm audit
   - bundle audit
   - Creates issues for vulnerabilities

**Auto-created PRs**:
- Labeled with `dependencies` and `automated`
- Assigned to repository owner
- Includes test results

### 5. Release

**File**: `.github/workflows/release.yml`

**Triggers**:
- Push tags matching `v*.*.*`
- Manual workflow dispatch with version input

**Jobs**:

1. **Create Release**
   - Generates changelog from commits
   - Categorizes changes (Features, Bug Fixes, Maintenance)
   - Creates GitHub release

2. **Build Artifacts**
   - Builds for multiple platforms (Linux, macOS)
   - Creates distribution archives
   - Uploads artifacts to release

3. **Docker Build**
   - Builds Rails API Docker image
   - Builds Next.js Docker image
   - Pushes to Docker Hub
   - Multi-platform builds (amd64, arm64)
   - Build caching

4. **Notify Release**
   - Slack notifications
   - Discord notifications
   - GitHub Discussion creation

**Required Secrets**:
- `DOCKER_USERNAME` - Docker Hub username
- `DOCKER_PASSWORD` - Docker Hub password/token
- `SLACK_WEBHOOK_URL` - Slack webhook (optional)

### 6. Production Health Check

**File**: `.github/workflows/health-check.yml`

**Triggers**:
- Scheduled: Every 30 minutes
- Manual workflow dispatch

**Jobs**:

1. **Health Check**
   - API health endpoint check
   - Frontend availability check
   - Database connectivity check
   - Redis connectivity check
   - Sidekiq status check
   - Creates issues on failure
   - Sends alerts

2. **Performance Metrics**
   - Lighthouse CI performance audit
   - API response time checks
   - Database query performance

3. **Uptime Monitoring**
   - Records uptime metrics
   - Calculates availability percentage
   - Uploads uptime logs (30 days retention)

**Alerts**:
- Creates GitHub issues for failures
- Labels: `production`, `health-check`, `urgent`

## Setup Instructions

### Required Secrets

Configure the following secrets in GitHub repository settings:

1. **Rails Credentials**
   ```
   RAILS_MASTER_KEY=<your-rails-master-key>
   ```

2. **Deployment Credentials** (if using specific platforms)
   ```
   VERCEL_TOKEN=<vercel-token>
   DOCKER_USERNAME=<docker-username>
   DOCKER_PASSWORD=<docker-password>
   ```

3. **Environment Variables**
   ```
   NEXT_PUBLIC_API_URL=<production-api-url>
   ```

4. **Notification Webhooks** (optional)
   ```
   SLACK_WEBHOOK_URL=<slack-webhook>
   ```

### Branch Protection Rules

Recommended branch protection for `main` and `develop`:

1. **Require status checks to pass**
   - CI Success
   - Lint & Format
   - Backend Tests
   - Frontend Tests
   - Build Check
   - Security Scan

2. **Require pull request reviews**
   - At least 1 approval required
   - Dismiss stale reviews

3. **Require conversation resolution**
   - All review comments must be resolved

4. **Include administrators**
   - Apply rules to administrators

### Environment Setup

Create environments in GitHub repository settings:

1. **staging**
   - Deployment branch: `develop`
   - Required reviewers: (optional)
   - Environment secrets and variables

2. **production**
   - Deployment branch: `main`
   - Required reviewers: (recommended)
   - Environment secrets and variables

## Workflow Badges

Add these badges to your README.md:

```markdown
![CI](https://github.com/iamgerwin/rails_nextjs_commentable_project/workflows/CI/badge.svg)
![CD](https://github.com/iamgerwin/rails_nextjs_commentable_project/workflows/CD/badge.svg)
![Code Quality](https://github.com/iamgerwin/rails_nextjs_commentable_project/workflows/Code%20Quality/badge.svg)
```

## Customization

### Deployment Targets

The CD workflow includes placeholder deployment commands. Customize based on your platform:

**Heroku**:
```bash
git push heroku main
heroku run rails db:migrate --app myapp
```

**Vercel**:
```bash
vercel deploy --prod --token=$VERCEL_TOKEN
```

**AWS**:
```bash
aws deploy create-deployment ...
```

**Railway**:
```bash
railway up
```

**Render**:
```bash
render deploy
```

### Notification Channels

Add notification logic in the deployment workflows:

**Slack**:
```bash
curl -X POST -H 'Content-type: application/json' \
  --data '{"text":"Deployment successful!"}' \
  $SLACK_WEBHOOK_URL
```

**Discord**:
```bash
curl -X POST -H 'Content-type: application/json' \
  --data '{"content":"Deployment successful!"}' \
  $DISCORD_WEBHOOK_URL
```

### Health Check URLs

Update health check workflow with actual production URLs:

```yaml
- name: Check API health
  run: |
    response=$(curl -s -o /dev/null -w "%{http_code}" https://api.example.com/health)
    if [ "$response" != "200" ]; then
      exit 1
    fi
```

## Troubleshooting

### Common Issues

1. **Tests failing in CI but passing locally**
   - Check environment variables
   - Verify database/Redis services are running
   - Check for time-dependent tests

2. **Build artifacts not found**
   - Verify artifact upload/download paths
   - Check artifact retention settings

3. **Deployment failures**
   - Verify all required secrets are set
   - Check deployment platform credentials
   - Review deployment logs

4. **Schema check failures**
   - Run `rails db:migrate` locally
   - Commit updated schema.rb file

### Getting Help

- Check workflow run logs in GitHub Actions tab
- Review job outputs and error messages
- Verify all required secrets are configured
- Consult deployment platform documentation

## Best Practices

1. **Keep workflows DRY**
   - Use reusable workflows for common tasks
   - Share actions across jobs

2. **Fail fast**
   - Run quick checks (linting) before slow ones (E2E tests)
   - Use `continue-on-error: false` for critical checks

3. **Optimize build times**
   - Use caching for dependencies
   - Run jobs in parallel where possible
   - Use matrix builds for multiple platforms

4. **Security**
   - Never commit secrets to repository
   - Use GitHub secrets for sensitive data
   - Rotate credentials regularly

5. **Monitoring**
   - Review failed workflows promptly
   - Monitor deployment success rates
   - Track build and deployment times

6. **Documentation**
   - Keep workflow documentation up to date
   - Document required secrets and variables
   - Provide troubleshooting guides
