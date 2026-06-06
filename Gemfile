source "https://rubygems.org"

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 8.1.3"
# Patched nokogiri (GHSA-c4rq-3m3g-8wgx, GHSA-v2fc-qm4h-8hqv); pulled in via Rails / Capybara
gem "nokogiri", ">= 1.19.3"
# Patched net-imap (CVE-2026-42245–42258); pulled in via mail / Action Mailbox
gem "net-imap", ">= 0.6.4"
# Patched faraday (CVE-2026-33637); pulled in via oauth2 / omniauth-google-oauth2
gem "faraday", ">= 2.14.2"
# The modern asset pipeline for Rails [https://github.com/rails/propshaft]
gem "propshaft"
# SQLite for local development and CI tests
gem "sqlite3", ">= 2.1", groups: %i[development test]
# Patched puma (CVE-2026-47736, CVE-2026-47737)
gem "puma", ">= 8.0.2"
# Use JavaScript with ESM import maps [https://github.com/rails/importmap-rails]
gem "importmap-rails"
# Hotwire's SPA-like page accelerator [https://turbo.hotwired.dev]
gem "turbo-rails"
# Hotwire's modest JavaScript framework [https://stimulus.hotwired.dev]
gem "stimulus-rails"
# Build JSON APIs with ease [https://github.com/rails/jbuilder]
gem "jbuilder"

# Use Active Model has_secure_password [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
# Used when available for new password digests; if the native gem cannot load, User falls back to PBKDF2 (see lib/password_digest.rb).
gem "bcrypt", "~> 3.1.7"

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem "tzinfo-data", platforms: %i[ windows jruby ]

# Use the database-backed adapters for Rails.cache, Active Job, and Action Cable
gem "solid_cache"
gem "solid_queue"
gem "solid_cable"

# Reduces boot times through caching; required in config/boot.rb
gem "bootsnap", require: false

# Deploy this application anywhere as a Docker container [https://kamal-deploy.org]
gem "kamal", require: false

# Add HTTP asset caching/compression and X-Sendfile acceleration to Puma [https://github.com/basecamp/thruster/]
gem "thruster", require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
gem "image_processing", "~> 1.2"

# Block profanity in user-generated text (see config/initializers/profanity.rb)
gem "moderate"

# Sign in with Google (OmniAuth)
gem "omniauth"
gem "omniauth-google-oauth2"
gem "omniauth-rails_csrf_protection"

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"

  # Audits gems for known security defects (use config/bundler-audit.yml to ignore issues)
  gem "bundler-audit", require: false

  # Static analysis for security vulnerabilities [https://brakemanscanner.org/]
  gem "brakeman", require: false

  # Omakase Ruby styling [https://github.com/rails/rubocop-rails-omakase/]
  gem "rubocop-rails-omakase", require: false
end

group :production do
  gem "pg", "~> 1.5"
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem "web-console"
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem "capybara"
  gem "selenium-webdriver"
end

gem "pagy", "~> 43.5"
