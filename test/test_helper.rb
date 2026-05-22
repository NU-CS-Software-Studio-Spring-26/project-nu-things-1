ENV["RAILS_ENV"] ||= "test"
# CI often sets ADMIN_EMAIL to blank; ||= does not replace "", which would leave admin unset.
ENV["ADMIN_EMAIL"] = "admin@u.northwestern.edu" if ENV["ADMIN_EMAIL"].to_s.strip.empty?
require_relative "../config/environment"
require "rails/test_help"

OmniAuth.config.test_mode = true

class ActionDispatch::IntegrationTest
  include ActiveJob::TestHelper
end

module ActiveSupport
  class TestCase
    # Run tests in parallel with specified workers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    # Add more helper methods to be used by all tests here...
    teardown do
      OmniAuth.config.mock_auth[:google_oauth2] = nil
    end

    def sign_in_as(user)
      OmniAuth.config.mock_auth[:google_oauth2] = OmniAuth::AuthHash.new(
        "provider" => "google_oauth2",
        "uid" => "test-google-uid-#{user.id}",
        "info" => {
          "email" => user.email,
          "first_name" => user.first_name
        },
        "extra" => { "raw_info" => { "email_verified" => true } }
      )
      get "/auth/google_oauth2/callback"
    end
  end
end
