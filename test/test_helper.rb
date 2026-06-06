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

    def create_lost_items_for_pagination(count)
      count.times do |i|
        LostItem.create!(
          title: "Pagination lost item #{i}",
          description: "Bulk record for pagination tests.",
          category: "Book",
          location_lost: "Test location",
          date_lost: Date.new(2026, 4, 1),
          contact_name: "Test User",
          contact_email: "lost_one@u.northwestern.edu",
          status: "open"
        )
      end
    end

    def create_found_items_for_pagination(count)
      count.times do |i|
        FoundItem.create!(
          title: "Pagination found item #{i}",
          description: "Bulk record for pagination tests.",
          category: "Book",
          location_found: "Test location",
          date_found: Date.new(2026, 4, 1),
          contact_name: "Test User",
          contact_email: "found_one@u.northwestern.edu",
          status: "unclaimed",
          image_url: "https://example.com/listing-photo.jpg"
        )
      end
    end

    def create_rental_items_for_pagination(count)
      count.times do |i|
        RentalItem.create!(
          title: "Pagination rental item #{i}",
          description: "Bulk record for pagination tests.",
          category: "Camping Gear",
          rental_price: 10,
          rental_period: "per_day",
          condition: "Good",
          location: "Campus",
          available_from: Date.new(2026, 5, 1),
          available_to: Date.new(2026, 12, 31),
          owner_name: "Test Owner",
          owner_email: "owner@u.northwestern.edu",
          deposit_required: 25,
          status: "available",
          image_url: "https://example.com/listing-photo.jpg"
        )
      end
    end

    def create_marketplace_listings_for_pagination(count)
      count.times do |i|
        MarketplaceListing.create!(
          title: "Pagination marketplace item #{i}",
          description: "Bulk record for pagination tests.",
          category: "Book",
          location: "Evanston",
          listing_type: "for_sale",
          price: 10,
          contact_name: "Test Seller",
          contact_email: "seller@u.northwestern.edu",
          status: "active",
          image_url: "https://example.com/listing-photo.jpg"
        )
      end
    end
  end
end
