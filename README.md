# Atlas Database Schema Management

This repository demonstrates automated database schema management using [Atlas](https://atlasgo.io) with [Supabase](https://supabase.com). It showcases a simple e-commerce database setup with user management and product catalogs.

## Prerequisites

- Docker
- Make
- [Atlas CLI](https://atlasgo.io/getting-started#installation)

## Quick Start

1. Clone the repository:
```bash
git clone <repository-url>
cd <repository-name>
```

2. Start the local development environment:
```bash
make setup  # Creates necessary directories
make local  # Starts PostgreSQL in Docker and creates databases
```

3. Verify the setup:
```bash
make inspect  # Should show the current schema
```

## Schema Structure

### User Schema (`demo_user`)
- `users`: Core user information (id, email, username, password_hash)
- `profiles`: Extended user profile data (bio, avatar, location)
- `sessions`: User session management

### Product Schema (`demo_product`)
- `categories`: Product categories
- `products`: Product information (name, price, stock)
- `reviews`: Product reviews linked to users

## Utility Functions

The demo includes several utility functions in the `demo_user` schema:

- `create_user_with_profile()`: Creates a new user with associated profile
- `create_session()`: Manages user session creation
- `validate_session()`: Validates user sessions
- `get_user_profile()`: Retrieves complete user profile information

## Development Workflow

### Local Development

1. Make changes to schema files in `config/schema/` or function files in `config/function/`
2. Check changes:
```bash
make check  # Performs a dry run
```

3. Apply changes:
```bash
make apply  # Applies changes to local database
```

### Available Commands

- `make setup`: Initialize development environment
- `make local`: Start local database
- `make lint`: Lint schema changes
- `make diff`: Show schema changes
- `make check`: Dry run schema changes
- `make apply`: Apply schema changes
- `make inspect`: Inspect current schema
- `make clean`: Clean up local environment

## GitHub Actions Integration

The repository includes automated workflows for schema management:

1. **Lint**: Runs on all PRs and pushes to main
   - Checks schema files for best practices and potential issues

2. **Check**: Runs on PRs only
   - Performs a dry run of schema changes
   - Helps identify potential issues before merging

3. **Apply**: Runs on push to main only
   - Applies schema changes to the production database
   - Requires `SUPABASE_URL` secret to be set

### Setting up GitHub Actions

1. Fork or clone this repository
2. In your GitHub repository settings, add the following secret:
   - `SUPABASE_URL`: Your Supabase database URL

## Best Practices

1. Always review migration files before applying them
2. Use the linting rules defined in `atlas.hcl` to maintain consistency
3. Keep functions modular and well-documented
4. Use appropriate indexes for better query performance
5. Implement proper foreign key constraints for data integrity

## Schema Visualization

Generate a visual representation of your schema:

```bash
atlas schema inspect --env demo --visualize
```

## Troubleshooting

1. If the local database is not responding:
```bash
make clean  # Stop the container
make local  # Start fresh
```

2. If migrations fail:
   - Check the Atlas debug logs (set `ATLAS_DEBUG=true`)
   - Verify database connectivity
   - Ensure all referenced schemas and extensions exist

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - feel free to use this as a template for your own projects.
