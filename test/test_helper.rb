ENV["RAILS_ENV"] ||= "test"
# CI often sets ADMIN_EMAIL to blank; ||= does not replace "", which would leave admin unset.
ENV["ADMIN_EMAIL"] = "admin@u.northwestern.edu" if ENV["ADMIN_EMAIL"].to_s.strip.empty?
require_relative "../config/environment"
require "rails/test_help"

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
    def sign_in_as(user)
      post session_url, params: { email: user.email, password: "password" }
    end
  end
end
