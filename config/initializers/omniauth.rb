# frozen_string_literal: true

Rails.application.config.middleware.use OmniAuth::Builder do
  client_id = ENV["GOOGLE_CLIENT_ID"].presence || Rails.application.credentials.dig(:google, :client_id)
  client_secret = ENV["GOOGLE_CLIENT_SECRET"].presence || Rails.application.credentials.dig(:google, :client_secret)

  # Heroku (and others) run `rake assets:precompile` in production before config vars exist on first
  # deploy. Skip the hard failure then; placeholders let the slug compile. Runtime dynos still require
  # real credentials below once this task is not asset precompilation.
  assets_precompile = ARGV.include?("assets:precompile")

  if Rails.env.production? && (client_id.blank? || client_secret.blank?)
    if assets_precompile
      Rails.logger.warn(
        "[OmniAuth] Google credentials missing during assets:precompile; using placeholders for the build. " \
        "Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET on the app before serving traffic."
      )
    else
      raise "Set GOOGLE_CLIENT_ID and GOOGLE_CLIENT_SECRET (or add google: client_id / client_secret to encrypted credentials) for Google sign-in."
    end
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
