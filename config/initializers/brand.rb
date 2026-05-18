# frozen_string_literal: true

# App constants (avoid config.x nested keys and dynamic config accessors in tests).
module Lofonu
  BRAND_NAME = "LoFoNU"
  BRAND_COLOR = "#4e2a84"
  # Single admin email from ENV; must match a registered User#email for admin? to be true.
  ADMIN_EMAIL = ENV["ADMIN_EMAIL"].to_s.strip.downcase.presence
end
