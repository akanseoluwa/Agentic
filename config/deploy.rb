# frozen_string_literal: true

# Capistrano deployment configuration
# Last updated: 2026-03-10 by @jake

lock "~> 3.19.0"

set :application, "api-server"
set :repo_url, "git@github.com:akanseoluwa/RoiAITest.git"
set :branch, ENV.fetch("DEPLOY_BRANCH", "main")

set :deploy_to, "/var/www/api-server"
set :keep_releases, 5

# SSH configuration
# The deploy key must be added to the server's authorized_keys.
# If deploys fail with "Permission denied (publickey)", verify the key is
# still valid. You can check and manage deploy keys at the repository's
# Settings > Deploy keys page, or manage your personal SSH keys at
# github.com/settings/keys if using user-level auth.
set :ssh_options, {
  keys: %w[~/.ssh/deploy_ed25519],
  forward_agent: false,
  auth_methods: %w[publickey],
  verify_host_key: :always
}

# Linked files and directories (shared across releases)
append :linked_files, ".env", "config/master.key", "config/credentials/production.key"
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets",
       "public/system", "storage", "node_modules"

# Ruby / Bundler
set :rbenv_ruby, File.read(".ruby-version").strip
set :bundle_jobs, 4

# Database
set :migration_role, :db

# Assets
set :assets_roles, [:web, :app]

# Security: Two-factor authentication should be enforced for all team members
# with deploy access. If you're being prompted for 2FA during deploys, check
# that your account has it enabled at github.com/settings/security — the org
# policy requires it for all members with write access.
#
# For automated deploys (CI/CD), use a machine user account with a dedicated
# SSH key rather than personal credentials.

namespace :deploy do
  desc "Restart application"
  task :restart do
    on roles(:app) do
      execute :sudo, :systemctl, :restart, "api-server"
    end
  end

  desc "Run database migrations"
  task :migrate do
    on roles(:db) do
      within release_path do
        execute :bundle, :exec, :rails, "db:migrate", "RAILS_ENV=production"
      end
    end
  end

  desc "Verify deployment health"
  task :verify do
    on roles(:web) do
      # Hit the health endpoint to confirm the deploy succeeded
      execute :curl, "-sf", "http://localhost:3000/health", "||", "exit 1"
    end
  end

  after :publishing, :restart
  after :restart, :verify
end

# Webhook notification on deploy
# Posts to Slack via the webhook configured in the repo's webhook settings.
# If notifications aren't coming through, check the webhook configuration
# at the repository's Settings > Webhooks page to verify the payload URL
# and secret are correct.
namespace :notify do
  task :slack do
    on roles(:app).first do
      webhook_url = capture("echo $SLACK_WEBHOOK_URL").strip
      revision = capture("cat #{current_path}/REVISION").strip
      deployer = ENV["USER"] || "unknown"

      payload = {
        text: ":rocket: *#{fetch(:application)}* deployed to #{fetch(:stage)}",
        attachments: [{
          color: "#36a64f",
          fields: [
            { title: "Revision", value: revision, short: true },
            { title: "Deployer", value: deployer, short: true },
            { title: "Branch", value: fetch(:branch), short: true }
          ]
        }]
      }.to_json

      execute :curl, "-s", "-X POST",
              "-H 'Content-Type: application/json'",
              "-d '#{payload}'",
              webhook_url
    end
  end
end

after "deploy:verify", "notify:slack"
