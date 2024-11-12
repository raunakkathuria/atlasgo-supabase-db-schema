.PHONY: setup local lint diff check apply inspect clean test-ci help

# Setup local development environment
setup:
	@echo "Setting up local development environment..."
	@if [ ! -d "migrations" ]; then \
		mkdir migrations; \
	fi

# Start local database
local:
	@if [ ! "$$(docker ps -q -f name=atlas-demo)" ]; then \
		docker run --rm -d --name atlas-demo \
			-e POSTGRES_PASSWORD=pass \
			-p 5432:5432 \
			supabase/postgres:15.6.1.132; \
	fi

	@echo "Waiting for PostgreSQL to be ready..."
	@until docker exec atlas-demo pg_isready -U postgres > /dev/null 2>&1; do \
		sleep 2; \
	done

	@echo "Creating prod database..."
	@docker exec -i atlas-demo psql -U postgres -d postgres --command "SELECT 1 FROM pg_database WHERE datname = 'prod'" | grep -q 1 || \
	docker exec -i atlas-demo psql -U postgres -d postgres --command 'CREATE DATABASE "prod";'
	
	@echo "Creating dev database..."
	@docker exec -i atlas-demo psql -U postgres -d postgres --command "SELECT 1 FROM pg_database WHERE datname = 'dev'" | grep -q 1 || \
	docker exec -i atlas-demo psql -U postgres -d postgres --command 'CREATE DATABASE "dev";'

	@echo "Applying current schema..."
	@make apply

# Lint schema changes
lint:
	atlas migrate lint --env common

# Create migration files
diff:
	atlas migrate diff --env common

# Check schema changes (dry run)
check:
	atlas schema apply --env common --dry-run

# Apply schema changes
apply:
	atlas schema apply --env common

# Inspect current schema
inspect:
	atlas schema inspect --env common

# Inspect schema visually
visualinspect:
	atlas schema inspect --env common -w

# Clean up local environment
clean:
	@echo "Cleaning up local environment..."
	@if [ "$$(docker ps -q -f name=atlas-demo)" ]; then \
		docker stop atlas-demo; \
	fi
	@echo "Cleanup complete"

# Test GitHub Actions locally
test-ci: test-ci-setup test-ci-run

# Setup for GitHub Actions local testing
test-ci-setup:
	@echo "Setting up GitHub Actions local testing environment..."
	@if ! command -v gh &> /dev/null; then \
		echo "Installing GitHub CLI..."; \
		sudo apt-get update && sudo apt-get install -y gh; \
	fi
	@if ! gh extension list | grep -q "nektos/gh-act"; then \
		echo "Installing act extension..."; \
		gh extension install https://github.com/nektos/gh-act; \
	fi

# Run GitHub Actions workflows locally
test-ci-run:
	@echo "Testing GitHub Actions workflows locally..."
	@echo "Testing push workflow..."
	gh act push
	@echo "Testing pull_request workflow..."
	gh act pull_request

# Help command
help:
	@echo "Available commands:"
	@echo "  make setup     		- Setup local development environment"
	@echo "  make local     		- Start local database and apply schema"
	@echo "  make lint      		- Lint schema changes"
	@echo "  make diff      		- Show schema changes"
	@echo "  make check     		- Check schema changes (dry run)"
	@echo "  make apply     		- Apply schema changes"
	@echo "  make inspect   		- Inspect current schema"
	@echo "  make visualinspect  	- Inspect current schema visually using atlasgo"
	@echo "  make clean     		- Clean up local environment"
	@echo "  make test-ci   		- Test GitHub Actions workflows locally"
	@echo "  make test-ci-setup 	- Setup GitHub Actions local testing"
	@echo "  make test-ci-run   	- Run GitHub Actions workflows locally"
