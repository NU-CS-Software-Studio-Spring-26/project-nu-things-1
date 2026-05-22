# frozen_string_literal: true

# App-wide brand constants (autoloaded from lib/ via config.autoload_lib).
module PurplePost
  BRAND_NAME = "Purple Post"
  BRAND_COLOR = "#4e2a84"

  # Read at call time so test/CI env (and db:test:prepare) can set ADMIN_EMAIL after boot.
  def self.admin_email
    email = ENV["ADMIN_EMAIL"].to_s.strip.downcase
    email.empty? ? nil : email
  end
end
