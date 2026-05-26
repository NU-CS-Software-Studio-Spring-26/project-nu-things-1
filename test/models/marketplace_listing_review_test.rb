require "test_helper"

class MarketplaceListingReviewTest < ActiveSupport::TestCase
  test "validates rating range" do
    review = MarketplaceListingReview.new(
      marketplace_listing: marketplace_listings(:for_sale_one),
      rating: 6,
      reviewer_name: "Test"
    )
    assert_not review.valid?
    assert_includes review.errors[:rating], "is not included in the list"
  end
end
