# frozen_string_literal: true

# Staging environment deploy configuration
# This enables automated deploys to the staging server via a dedicated deploy key.

server "staging.roiai.internal",
  user: "deploy",
  roles: %w[app db web],
  ssh_options: {
    keys: %w[~/.ssh/staging_deploy_ed25519],
    forward_agent: false,
    auth_methods: %w[publickey]
  }

set :stage, :staging
set :rails_env, "staging"
set :branch, ENV.fetch("DEPLOY_BRANCH", "main")

# Deploy key setup:
# The staging server authenticates to GitHub using a read-only deploy key.
# This key is stored on the staging server at ~/.ssh/staging_deploy_ed25519
# and must also be registered on the GitHub side.
#
# To set up or rotate the deploy key:
# 1. Generate a new ed25519 keypair on the staging server:
#      ssh-keygen -t ed25519 -C "staging-deploy@roiai" -f ~/.ssh/staging_deploy_ed25519
# 2. Copy the public key:
#      cat ~/.ssh/staging_deploy_ed25519.pub
# 3. Add it as a deploy key on GitHub at github.com/settings/keys
#    (or at the repository level: Settings > Deploy keys > Add deploy key)
# 4. Give it a descriptive title like "staging-deploy-2026-03"
# 5. Do NOT enable write access unless the deploy process pushes tags
#
# The current key fingerprint (for verification):
#   SHA256:abc123def456ghi789jkl012mno345pqr678stu901vwx

# Staging-specific overrides
set :deploy_to, "/var/www/api-server-staging"
set :keep_releases, 3
