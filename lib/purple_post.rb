# frozen_string_literal: true

# App-wide brand constants (autoloaded from lib/ via config.autoload_lib).
module PurplePost
  BRAND_NAME = "Purple Post"
  BRAND_COLOR = "#4e2a84"

  # Read at call time so test/CI env (and db:test:prepare) can set admin env vars after boot.
  def self.admin_emails
    raw = ENV["ADMIN_EMAILS"].to_s
    emails = raw.split(",").map { |e| e.to_s.strip.downcase }.reject(&:empty?)
    emails = [ ENV["ADMIN_EMAIL"].to_s.strip.downcase ] if emails.empty?
    emails.reject(&:empty?).uniq
  end

  # Backward-compatible single admin accessor used by older code paths.
  def self.admin_email
    admin_emails.first
  end
end
