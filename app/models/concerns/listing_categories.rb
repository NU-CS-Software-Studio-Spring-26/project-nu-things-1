# frozen_string_literal: true

# Shared category values for lost, found, rental, and marketplace listings.
module ListingCategories
  VALUES = %w[Book Camping\ Gear Electronics Furniture Tools Sports\ Equipment Accessories Other].freeze

  LOST_FOUND_FILTER_EXCLUDED = [
    "Book",
    "Camping Gear",
    "School supplies",
    "Wallets"
  ].freeze
end
