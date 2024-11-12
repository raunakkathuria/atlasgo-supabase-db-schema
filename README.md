# Atlas Supabase Database Schema

A production-ready database schema management solution using [Atlas](https://atlasgo.io) and [Supabase](https://supabase.com). This repository provides a streamlined approach to managing PostgreSQL database schemas with automated deployments.

## Technologies

- **[Atlas](https://atlasgo.io)**: A modern tool for managing database schemas as code
  - [Documentation](https://atlasgo.io/docs)
  - [Schema Management](https://atlasgo.io/concepts/declarative-vs-versioned)

- **[Supabase](https://supabase.com)**: An open-source Firebase alternative
  - [Documentation](https://supabase.com/docs)
  - [Database](https://supabase.com/docs/guides/database)

## Features

• Automated schema management with Atlas and GitHub Actions
• Supabase-compatible PostgreSQL schema definitions
• Built-in user authentication and product management schemas
• Production-grade utility functions and database triggers
• Docker-based local development environment
• Comprehensive CI/CD pipeline for safe schema deployments

## Quick Start

1. Clone the repository:
```bash
git clone https://github.com/yourusername/atlas-supabase-db-schema.git
cd atlas-supabase-db-schema
```

2. Start the local development environment:
```bash
make setup  # Creates necessary directories
make local  # Starts PostgreSQL in Docker and creates databases
```

3. Verify the setup:
```bash
make inspect  # Show the current schema
# or
make visualinspect  # Open interactive schema visualization in browser
```

## Schema Structure

### User Schema (`org_user`)
- `users`: Core user information (id, email, username, password_hash)
- `profiles`: Extended user profile data (bio, avatar, location)
- `sessions`: User session management

### Product Schema (`org_product`)
- `categories`: Product categories
- `products`: Product information (name, price, stock)
- `reviews`: Product reviews linked to users

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
- `make check`: Check schema changes (dry run)
- `make apply`: Apply schema changes
- `make inspect`: Inspect current schema
- `make visualinspect`: Open interactive schema visualization in browser
- `make clean`: Clean up local environment

## GitHub Actions Workflow

The repository uses [Atlas Cloud](https://atlasgo.io/cloud/getting-started) for schema management with integrated GitHub Actions workflow.

### Workflow Structure

The workflow consists of a single job that:
1. Sets up PostgreSQL using Supabase's image
2. Creates development and production databases
3. Configures Atlas with cloud integration
4. Performs three main operations:
   - **Lint**: Validates schema changes using Atlas Cloud
   - **Push**: Pushes migration directory to Atlas Cloud (on master)
   - **Apply**: Applies migrations using Atlas Cloud (on master)

### Testing Locally

1. Install prerequisites:
```bash
# Install GitHub CLI
sudo apt install gh  # Ubuntu/Debian
brew install gh     # macOS
scoop install gh    # Windows

# Install act extension
gh extension install https://github.com/nektos/gh-act
```

2. Create a `.env` file from template:
```bash
cp .env.example .env
# Edit .env with your values
```

3. Run workflow tests:
```bash
# Test entire workflow
make test-ci

# Test with secrets
gh act -s SUPABASE_DATABASE_URL=your_url_here -s ATLAS_CLOUD_TOKEN=your_token_here
```

### Workflow Configuration

The workflow automatically runs on:
- Push to master branch
- Pull request creation/update
- Only when changes are made to:
  - `config/**` (includes both schema and function files)
  - `atlas.hcl`
  - `.github/workflows/atlas.yml` (on push to master)

### Environment Variables and Secrets

Required secrets:
- `SUPABASE_DATABASE_URL`: Your [Supabase Database Connection String](https://supabase.com/docs/guides/database/connecting-to-postgres#connection-strings)
- `ATLAS_CLOUD_TOKEN`: Your [Atlas Cloud Token](https://atlasgo.io/cloud/getting-started#authentication)

Optional variables (set in .env):
- `ATLAS_DEBUG`: Enable debug logging
- `GITHUB_TOKEN`: For local testing

## Best Practices

1. Always review migration files before applying
2. Use the [linting rules](https://atlasgo.io/lint/analyzers) defined in `atlas.hcl`
3. Keep functions modular and well-documented
4. Use appropriate indexes for better query performance
5. Implement proper foreign key constraints
6. Follow [Atlas Best Practices](https://atlasgo.io/concepts/best-practices)
7. Utilize [Supabase Database Features](https://supabase.com/docs/guides/database/overview)

## Schema Visualization

Generate a visual representation of your schema:

```bash
# CLI-based visualization
make inspect

# Interactive browser-based visualization
make visualinspect
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
   - Consult [Atlas Troubleshooting Guide](https://atlasgo.io/getting-started/troubleshooting)
   - Check [Supabase Status](https://status.supabase.com)

3. GitHub Actions Local Testing Issues:
   - Docker permission issues:
     ```bash
     sudo chmod 666 /var/run/docker.sock
     ```
   - PostgreSQL connection issues:
     ```bash
     # Verify PostgreSQL is running
     docker ps
     # Check logs
     docker logs atlas-demo
     ```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - feel free to use this as a template for your own projects.
