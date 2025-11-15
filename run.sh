#!/bin/bash

# Rails + Next.js Commentable Project Runner
# This script simplifies running all applications in the monorepo

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}ℹ ${1}${NC}"
}

print_success() {
    echo -e "${GREEN}✓ ${1}${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ ${1}${NC}"
}

print_error() {
    echo -e "${RED}✗ ${1}${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check prerequisites
check_prerequisites() {
    print_info "Checking prerequisites..."

    local missing_deps=()

    if ! command_exists node; then
        missing_deps+=("Node.js (>= 20.0.0)")
    fi

    if ! command_exists ruby; then
        missing_deps+=("Ruby (>= 3.3.6)")
    fi

    if ! command_exists bundle; then
        missing_deps+=("Bundler")
    fi

    # PostgreSQL and Redis are optional for development (using SQLite)
    # Only warn if not available
    if ! command_exists psql; then
        print_warning "PostgreSQL not found (optional for production)"
    fi

    if ! command_exists redis-cli; then
        print_warning "Redis not found (optional, needed for Sidekiq)"
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing required dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        exit 1
    fi

    print_success "All required prerequisites met"
}

# Function to check if services are running
check_services() {
    print_info "Checking optional services..."

    local warnings=0

    # Check PostgreSQL (optional for production)
    if command_exists pg_isready; then
        if ! pg_isready -q 2>/dev/null; then
            print_warning "PostgreSQL is not running (optional for production)"
            warnings=$((warnings + 1))
        else
            print_success "PostgreSQL is running"
        fi
    fi

    # Check Redis (optional for Sidekiq)
    if command_exists redis-cli; then
        if ! redis-cli ping > /dev/null 2>&1; then
            print_warning "Redis is not running (optional for Sidekiq background jobs)"
            warnings=$((warnings + 1))
        else
            print_success "Redis is running"
        fi
    fi

    if [ $warnings -eq 0 ]; then
        print_success "All available services are running"
    else
        print_info "Development will use SQLite (no PostgreSQL needed)"
        print_info "Background jobs disabled (no Redis needed)"
    fi
}

# Function to install dependencies
install_deps() {
    print_info "Installing dependencies..."

    # Install Node.js dependencies
    print_info "Installing Node.js dependencies..."
    npm install

    # Install Rails dependencies
    if [ -d "apps/api" ] && [ -f "apps/api/Gemfile" ]; then
        print_info "Installing Rails dependencies..."
        cd apps/api
        bundle install
        cd ../..
    fi

    print_success "Dependencies installed"
}

# Function to setup database
setup_db() {
    print_info "Setting up database..."

    if [ -d "apps/api" ]; then
        cd apps/api

        # Check if database exists
        if bundle exec rails db:version > /dev/null 2>&1; then
            print_info "Database already exists"
        else
            print_info "Creating database..."
            bundle exec rails db:create
        fi

        print_info "Running migrations..."
        bundle exec rails db:migrate

        if [ "$1" == "--seed" ]; then
            print_info "Seeding database with sample data..."
            bundle exec rails db:seed
        fi

        cd ../..
        print_success "Database setup complete (using SQLite)"
    else
        print_warning "Rails API not found, skipping database setup"
    fi
}

# Function to start Rails API
start_api() {
    print_info "Starting Rails API on port 3000..."

    if [ -d "apps/api" ]; then
        cd apps/api
        bundle exec rails server -p 3000
    else
        print_error "Rails API not found at apps/api"
        exit 1
    fi
}

# Function to start Next.js web
start_web() {
    print_info "Starting Next.js web on port 4200..."

    if [ -d "apps/web" ]; then
        # Use Nx to run the dev target with custom port
        PORT=4200 npx nx dev web
    else
        print_error "Next.js web not found at apps/web"
        exit 1
    fi
}

# Function to start all services
start_all() {
    print_info "Starting all services..."

    # Check for .env files
    if [ ! -f "apps/web/.env.local" ]; then
        print_warning "apps/web/.env.local not found"
        print_info "Creating .env.local with default values..."
        cat > apps/web/.env.local << EOF
NEXT_PUBLIC_API_URL=http://localhost:3000
NEXT_PUBLIC_API_VERSION=v1
EOF
        print_success "Created apps/web/.env.local"
    fi

    # Check if tmux or screen is available for running multiple processes
    if command_exists tmux; then
        print_info "Using tmux to manage processes..."

        # Kill existing session if it exists
        tmux kill-session -t rails_nextjs_app 2>/dev/null || true

        # Create new tmux session
        tmux new-session -d -s rails_nextjs_app

        # Window 0: Rails API
        tmux rename-window -t rails_nextjs_app:0 'Rails API'
        tmux send-keys -t rails_nextjs_app:0 "cd apps/api && bundle exec rails server -p 3000" C-m

        # Window 1: Next.js Web
        tmux new-window -t rails_nextjs_app:1 -n 'Next.js Web'
        tmux send-keys -t rails_nextjs_app:1 "PORT=4200 npx nx dev web" C-m

        # Window 2: Sidekiq (if Redis available)
        if command_exists redis-cli && redis-cli ping > /dev/null 2>&1; then
            tmux new-window -t rails_nextjs_app:2 -n 'Sidekiq'
            tmux send-keys -t rails_nextjs_app:2 "cd apps/api && bundle exec sidekiq" C-m
        fi

        # Select first window
        tmux select-window -t rails_nextjs_app:0

        # Attach to session
        print_success "All services started in tmux session 'rails_nextjs_app'"
        echo ""
        print_info "tmux Commands:"
        print_info "  Switch windows: Ctrl+b then 0/1/2"
        print_info "  Detach: Ctrl+b then d"
        print_info "  Kill session: tmux kill-session -t rails_nextjs_app"
        echo ""
        print_info "Service URLs:"
        print_info "  Rails API: http://localhost:3000"
        print_info "  Next.js Web: http://localhost:4200"
        print_info "  API Docs: http://localhost:3000/api-docs"
        echo ""

        sleep 2
        tmux attach -t rails_nextjs_app
    else
        print_warning "tmux not found. Starting services in background..."
        print_info "Install tmux for better management: brew install tmux"

        # Use background processes with trap for cleanup
        trap "kill 0" EXIT

        (cd apps/api && bundle exec rails server -p 3000) &
        API_PID=$!

        (PORT=4200 npx nx dev web) &
        WEB_PID=$!

        # Start Sidekiq if Redis is available
        if command_exists redis-cli && redis-cli ping > /dev/null 2>&1; then
            (cd apps/api && bundle exec sidekiq) &
            SIDEKIQ_PID=$!
            print_info "Sidekiq PID: $SIDEKIQ_PID"
        fi

        print_success "Services started in background"
        print_info "Rails API PID: $API_PID"
        print_info "Next.js Web PID: $WEB_PID"
        echo ""
        print_info "Service URLs:"
        print_info "  Rails API: http://localhost:3000"
        print_info "  Next.js Web: http://localhost:4200"
        echo ""
        print_info "Press Ctrl+C to stop all services"

        wait
    fi
}

# Function to run tests
run_tests() {
    print_info "Running tests..."

    # Run Rails tests
    if [ -d "apps/api" ]; then
        print_info "Running Rails tests..."
        cd apps/api
        bundle exec rspec
        cd ../..
    fi

    # Run Next.js tests
    if [ -d "apps/web" ]; then
        print_info "Running Next.js tests..."
        npx nx test web
    fi

    print_success "All tests completed"
}

# Function to run linters
run_lint() {
    print_info "Running linters..."
    npm run lint
    print_success "Linting completed"
}

# Function to build all apps
build_all() {
    print_info "Building all applications..."
    npm run build
    print_success "Build completed"
}

# Function to run e2e tests
run_e2e() {
    print_info "Running end-to-end tests..."
    npm run e2e
    print_success "E2E tests completed"
}

# Function to show help
show_help() {
    cat << EOF
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
${BLUE}  Rails + Next.js Commentable Project Runner${NC}
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

${GREEN}USAGE${NC}
  ./run.sh [command] [options]

${GREEN}COMMANDS${NC}
  ${YELLOW}dev${NC}              Start all services in development mode
  ${YELLOW}api${NC}              Start only the Rails API server
  ${YELLOW}web${NC}              Start only the Next.js web application
  ${YELLOW}install${NC}          Install all dependencies (Node.js + Ruby)
  ${YELLOW}setup${NC}            Setup database (create, migrate)
  ${YELLOW}setup --seed${NC}     Setup database and run seeds with sample data
  ${YELLOW}test${NC}             Run all tests (Rails RSpec + Next.js)
  ${YELLOW}lint${NC}             Run linters on all code
  ${YELLOW}build${NC}            Build all applications for production
  ${YELLOW}e2e${NC}              Run end-to-end tests with Playwright
  ${YELLOW}check${NC}            Check prerequisites and services
  ${YELLOW}help${NC}             Show this help message

${GREEN}EXAMPLES${NC}
  ${YELLOW}./run.sh dev${NC}              # Start all services with tmux
  ${YELLOW}./run.sh install${NC}          # Install all dependencies
  ${YELLOW}./run.sh setup --seed${NC}     # Setup database with sample users
  ${YELLOW}./run.sh api${NC}              # Start only Rails API
  ${YELLOW}./run.sh web${NC}              # Start only Next.js frontend
  ${YELLOW}./run.sh test${NC}             # Run all tests
  ${YELLOW}./run.sh check${NC}            # Verify environment

${GREEN}SERVICE URLS${NC}
  ${BLUE}Rails API:${NC}          http://localhost:3000
  ${BLUE}Next.js Web:${NC}        http://localhost:4200
  ${BLUE}API Docs (Swagger):${NC} http://localhost:3000/api-docs

${GREEN}DEVELOPMENT STACK${NC}
  ${BLUE}Backend:${NC}  Rails 8.1.1 (API mode) with SQLite
  ${BLUE}Frontend:${NC} Next.js 15.2.4 (App Router) with TypeScript
  ${BLUE}Build:${NC}    Nx Monorepo 20.8.2
  ${BLUE}Testing:${NC}  RSpec + Playwright

${GREEN}SAMPLE USERS (after setup --seed)${NC}
  ${BLUE}Admin:${NC}      admin@example.com      (password: admin@example.com)
  ${BLUE}Moderator:${NC}  moderator@example.com  (password: moderator@example.com)
  ${BLUE}User:${NC}       user@example.com       (password: user@example.com)

${GREEN}TMUX COMMANDS (when using tmux)${NC}
  ${YELLOW}Switch windows:${NC}  Ctrl+b then 0/1/2
  ${YELLOW}Detach:${NC}          Ctrl+b then d
  ${YELLOW}Reattach:${NC}        tmux attach -t rails_nextjs_app
  ${YELLOW}Kill session:${NC}    tmux kill-session -t rails_nextjs_app
  ${YELLOW}List sessions:${NC}   tmux ls

${GREEN}TIPS${NC}
  • Install tmux for better process management:
    ${YELLOW}brew install tmux${NC} (macOS) or ${YELLOW}apt-get install tmux${NC} (Linux)

  • View Rails logs:
    ${YELLOW}tail -f apps/api/log/development.log${NC}

  • Reset database:
    ${YELLOW}cd apps/api && bundle exec rails db:reset && bundle exec rails db:seed${NC}

  • Clean build:
    ${YELLOW}rm -rf node_modules apps/web/.next && npm install${NC}

${GREEN}TROUBLESHOOTING${NC}
  • Port 3000 already in use: ${YELLOW}lsof -ti:3000 | xargs kill -9${NC}
  • Port 4200 already in use: ${YELLOW}lsof -ti:4200 | xargs kill -9${NC}
  • Database locked: Stop all Rails processes and restart
  • Frontend not loading: Check ${YELLOW}apps/web/.env.local${NC} exists

${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}
For more information, see: ${YELLOW}README.md${NC}
${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}

EOF
}

# Main script logic
main() {
    case "${1:-help}" in
        dev|start)
            check_prerequisites
            check_services
            start_all
            ;;
        api)
            check_prerequisites
            check_services
            start_api
            ;;
        web)
            check_prerequisites
            start_web
            ;;
        install|deps)
            check_prerequisites
            install_deps
            ;;
        setup|db:setup)
            check_prerequisites
            check_services
            setup_db "$2"
            ;;
        test|tests)
            check_prerequisites
            run_tests
            ;;
        lint)
            run_lint
            ;;
        build)
            build_all
            ;;
        e2e)
            check_prerequisites
            run_e2e
            ;;
        check)
            check_prerequisites
            check_services
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            print_error "Unknown command: $1"
            echo ""
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
