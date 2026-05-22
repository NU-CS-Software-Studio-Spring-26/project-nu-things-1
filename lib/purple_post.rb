# frozen_string_literal: true

# App-wide brand constants (autoloaded from lib/ via config.autoload_lib).
module PurplePost
  BRAND_NAME = "Purple Post"
  BRAND_COLOR = "#4e2a84"

  _admin_email = ENV["ADMIN_EMAIL"].to_s.strip.downcase
  ADMIN_EMAIL = _admin_email.empty? ? nil : _admin_email
end
