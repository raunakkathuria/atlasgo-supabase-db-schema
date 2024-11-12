.PHONY: setup local lint diff check apply inspect clean help

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

	@echo "Creating demo database..."
	@docker exec -i atlas-demo psql -U postgres -d postgres --command "SELECT 1 FROM pg_database WHERE datname = 'demo'" | grep -q 1 || \
	docker exec -i atlas-demo psql -U postgres -d postgres --command "CREATE DATABASE demo"
	
	@echo "Creating demo_dev database..."
	@docker exec -i atlas-demo psql -U postgres -d postgres --command "SELECT 1 FROM pg_database WHERE datname = 'demo_dev'" | grep -q 1 || \
	docker exec -i atlas-demo psql -U postgres -d postgres --command "CREATE DATABASE demo_dev"

	@echo "Applying current schema..."
	@make apply

# Lint schema changes
lint:
	atlas migrate lint --env demo

# Create migration files
diff:
	atlas migrate diff --env demo

# Check schema changes (dry run)
check:
	atlas schema apply --env demo --dry-run

# Apply schema changes
apply:
	atlas schema apply --env demo

# Inspect current schema
inspect:
	atlas schema inspect --env demo

# Inspect schema visually
visualinspect:
	atlas schema inspect --env demo -w

# Clean up local environment
clean:
	@echo "Cleaning up local environment..."
	@if [ "$$(docker ps -q -f name=atlas-demo)" ]; then \
		docker stop atlas-demo; \
	fi
	@echo "Cleanup complete"

# Help command
help:
	@echo "Available commands:"
	@echo "  make setup   		- Setup local development environment"
	@echo "  make local   		- Start local database and apply schema"
	@echo "  make lint    		- Lint schema changes"
	@echo "  make diff    		- Show schema changes"
	@echo "  make check   		- Check schema changes (dry run)"
	@echo "  make apply   		- Apply schema changes"
	@echo "  make inspect 		- Inspect current schema"
	@echo "  make visualinspect - Inspect visually current schema using atlasgo"
	@echo "  make clean   		- Clean up local environment"
