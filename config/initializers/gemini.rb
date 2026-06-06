# frozen_string_literal: true

Rails.application.config.x.gemini_api_key =
  ENV["GEMINI_API_KEY"].presence || Rails.application.credentials.dig(:gemini, :api_key)

Rails.application.config.x.gemini_model = ENV.fetch("GEMINI_MODEL", "gemini-2.0-flash")
