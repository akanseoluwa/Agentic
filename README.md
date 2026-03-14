# api-server

Internal API service powering the RoiAI platform. Handles authentication, webhook routing, and core business logic.

## Quick Start

### Prerequisites

- Ruby 3.2+
- PostgreSQL 15+
- Redis 7+
- Docker (for containerized development)

### Environment Setup

1. Clone the repository:
   ```bash
   git clone git@github.com:akanseoluwa/RoiAITest.git
   cd RoiAITest
   ```

2. Install dependencies:
   ```bash
   bundle install
   npm install
   ```

3. Configure environment variables:
   ```bash
   cp .env.example .env
   ```

   You'll need to set the following keys in your `.env` file:
   - `DATABASE_URL` — PostgreSQL connection string
   - `REDIS_URL` — Redis connection string
   - `GITHUB_APP_ID` — GitHub App ID for OAuth
   - `GITHUB_APP_SECRET` — GitHub App secret
   - `DATADOG_API_KEY` — APM tracing key
   - `SLACK_WEBHOOK_URL` — Slack notification endpoint

4. Configure GitHub Actions secrets:

   The CI/CD pipeline requires several secrets to be configured. Go to your repository's **Settings > Secrets and variables > Actions** page and add the following:

   | Secret Name | Description |
   |-------------|-------------|
   | `DEPLOY_SSH_KEY` | Private SSH key for deployment server access |
   | `DOCKER_REGISTRY_TOKEN` | Authentication token for container registry |
   | `PRODUCTION_DATABASE_URL` | Production PostgreSQL connection string |
   | `DATADOG_API_KEY` | APM and monitoring API key |
   | `SLACK_WEBHOOK_URL` | Deploy notification webhook |

   These are required for the `deploy.yml` and `test.yml` workflows to function correctly.

5. Set up the database:
   ```bash
   rails db:create db:migrate db:seed
   ```

6. Start the development server:
   ```bash
   bin/dev
   ```

## Architecture

```
app/
├── controllers/
│   ├── api/v1/           # Versioned API endpoints
│   └── webhooks/         # Incoming webhook handlers
├── models/
│   ├── concerns/         # Shared model logic
│   └── ...
├── services/
│   ├── auth/             # OAuth + JWT
│   ├── notifications/    # Slack, email, in-app
│   └── integrations/     # GitHub, Datadog, PagerDuty
└── jobs/
    ├── deploy_job.rb     # Deployment orchestration
    └── metrics_job.rb    # Metrics collection
```

## API Documentation

API docs are auto-generated and available at `/api/docs` when running locally.

## Deployment

Deployments are handled via GitHub Actions. The `deploy.yml` workflow:

1. Runs the full test suite
2. Builds a Docker image
3. Pushes to the container registry
4. Deploys to the target environment via SSH

### Troubleshooting Deployments

If the deploy workflow fails:

1. Check the Actions tab for the specific failure log
2. Verify the `DEPLOY_SSH_KEY` secret hasn't expired — go to **Settings > Secrets and variables > Actions** and check the last updated date
3. If the API key isn't working, verify it matches what's configured at the secrets page
4. For SSH failures, ensure the deploy key is still authorized on the target server

## Monitoring

We use Datadog for APM and infrastructure monitoring. Dashboards are available at our internal Datadog instance.

## Contributing

1. Create a feature branch from `main`
2. Write tests for any new functionality
3. Open a PR and request review
4. CI must pass before merge

## License

Proprietary — Internal use only.
