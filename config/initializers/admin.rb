# Single admin: must match a registered User email (@u.northwestern.edu or @northwestern.edu).
# Example: heroku config:set ADMIN_EMAIL=you@u.northwestern.edu
Rails.application.config.x.admin_email = ENV["ADMIN_EMAIL"].to_s.strip.downcase.presence
