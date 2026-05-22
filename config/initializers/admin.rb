# Legacy config.x mirror; canonical value is PurplePost::ADMIN_EMAIL (config/initializers/brand.rb).
# Example: heroku config:set ADMIN_EMAIL=you@u.northwestern.edu
Rails.application.config.x.admin_email = ENV["ADMIN_EMAIL"].to_s.strip.downcase.presence
