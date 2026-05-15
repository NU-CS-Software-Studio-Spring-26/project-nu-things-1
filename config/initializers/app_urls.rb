# frozen_string_literal: true

# Public source repository (optional). Leave unset until you have a URL.
Rails.application.config.x.source_code_url = ENV["APP_SOURCE_CODE_URL"].to_s.strip

# Shown in Privacy for data-deletion requests. Falls back to admin email in views when unset.
Rails.application.config.x.privacy_contact_email = ENV["PRIVACY_CONTACT_EMAIL"].to_s.strip.downcase.presence
