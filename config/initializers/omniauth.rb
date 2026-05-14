# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  client_id = ENV["GOOGLE_CLIENT_ID"].presence || Rails.application.credentials.dig(:google, :client_id)
  client_secret = ENV["GOOGLE_CLIENT_SECRET"].presence || Rails.application.credentials.dig(:google, :client_secret)

  if Rails.env.production? && (client_id.blank? || client_secret.blank?)
    raise "Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET (or add google: client_id / client_secret to encrypted credentials) for Google sign-in."
  end

  # Development without keys still boots; sign-in redirects to Google and fails until credentials are configured.
  client_id ||= "unset-google-client-id"
  client_secret ||= "unset-google-client-secret"

  provider :google_oauth2, client_id, client_secret,
           {
             scope: "email,profile",
             prompt: "select_account",
             access_type: "online",
             image_aspect_ratio: "square",
             image_size: 50
           }
end

OmniAuth.config.allowed_request_methods = [ :get, :post ]
