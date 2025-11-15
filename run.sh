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
        missing_deps+=("Ruby (>= 3.3.0)")
    fi

    if ! command_exists bundle; then
        missing_deps+=("Bundler")
    fi

    if ! command_exists psql; then
        missing_deps+=("PostgreSQL (>= 14.0)")
    fi

    if ! command_exists redis-cli; then
        missing_deps+=("Redis (>= 7.0)")
    fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        print_error "Missing dependencies:"
        for dep in "${missing_deps[@]}"; do
            echo "  - $dep"
        done
        exit 1
    fi

    print_success "All prerequisites met"
}

# Function to check if services are running
check_services() {
    print_info "Checking services..."

    # Check PostgreSQL
    if ! pg_isready -q; then
        print_warning "PostgreSQL is not running. Please start PostgreSQL."
        return 1
    fi

    # Check Redis
    if ! redis-cli ping > /dev/null 2>&1; then
        print_warning "Redis is not running. Please start Redis."
        return 1
    fi

    print_success "All services are running"
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

        if ! bundle exec rails db:exists 2>/dev/null; then
            print_info "Creating database..."
            bundle exec rails db:create
        fi

        print_info "Running migrations..."
        bundle exec rails db:migrate

        if [ "$1" == "--seed" ]; then
            print_info "Seeding database..."
            bundle exec rails db:seed
        fi

        cd ../..
        print_success "Database setup complete"
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
        cd apps/web
        npm run dev -- -p 4200
    else
        print_error "Next.js web not found at apps/web"
        exit 1
    fi
}

# Function to start all services
start_all() {
    print_info "Starting all services..."

    # Check if tmux or screen is available for running multiple processes
    if command_exists tmux; then
        print_info "Using tmux to manage processes..."

        # Create new tmux session
        tmux new-session -d -s rails_nextjs_app

        # Split window for API
        tmux send-keys -t rails_nextjs_app "cd apps/api && bundle exec rails server -p 3000" C-m

        # Create new window for Web
        tmux new-window -t rails_nextjs_app
        tmux send-keys -t rails_nextjs_app "cd apps/web && npm run dev -- -p 4200" C-m

        # Create new window for Sidekiq
        tmux new-window -t rails_nextjs_app
        tmux send-keys -t rails_nextjs_app "cd apps/api && bundle exec sidekiq" C-m

        # Attach to session
        print_success "All services started in tmux session 'rails_nextjs_app'"
        print_info "To attach: tmux attach -t rails_nextjs_app"
        print_info "To detach: Ctrl+b then d"
        print_info "To kill: tmux kill-session -t rails_nextjs_app"

        tmux attach -t rails_nextjs_app
    else
        print_warning "tmux not found. Starting services sequentially..."
        print_info "Install tmux for better multi-process management: brew install tmux"

        # Use background processes with trap for cleanup
        trap "kill 0" EXIT

        cd apps/api && bundle exec rails server -p 3000 &
        API_PID=$!

        cd apps/web && npm run dev -- -p 4200 &
        WEB_PID=$!

        print_success "Services started"
        print_info "Rails API PID: $API_PID"
        print_info "Next.js Web PID: $WEB_PID"
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
${BLUE}Rails + Next.js Commentable Project Runner${NC}

${GREEN}Usage:${NC}
  ./run.sh [command] [options]

${GREEN}Commands:${NC}
  ${YELLOW}dev${NC}              Start all services in development mode
  ${YELLOW}api${NC}              Start only the Rails API server
  ${YELLOW}web${NC}              Start only the Next.js web application
  ${YELLOW}install${NC}          Install all dependencies
  ${YELLOW}setup${NC}            Setup database (create, migrate)
  ${YELLOW}setup --seed${NC}     Setup database and run seeds
  ${YELLOW}test${NC}             Run all tests
  ${YELLOW}lint${NC}             Run linters
  ${YELLOW}build${NC}            Build all applications
  ${YELLOW}e2e${NC}              Run end-to-end tests
  ${YELLOW}check${NC}            Check prerequisites and services
  ${YELLOW}help${NC}             Show this help message

${GREEN}Examples:${NC}
  ./run.sh dev              # Start all services
  ./run.sh api              # Start only Rails API
  ./run.sh setup --seed     # Setup database with seeds
  ./run.sh test             # Run all tests

${GREEN}Service URLs:${NC}
  Rails API:     http://localhost:3000
  Next.js Web:   http://localhost:4200
  API Docs:      http://localhost:3000/api-docs

${GREEN}Tips:${NC}
  - Install tmux for better multi-process management: ${YELLOW}brew install tmux${NC}
  - Stop all services: ${YELLOW}Ctrl+C${NC} or ${YELLOW}tmux kill-session -t rails_nextjs_app${NC}
  - View logs: ${YELLOW}tail -f apps/api/log/development.log${NC}

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
