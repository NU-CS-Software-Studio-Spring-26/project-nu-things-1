require "test_helper"

class RentalReviewTest < ActiveSupport::TestCase
  test "validates rating range" do
    review = RentalReview.new(rental_item: rental_items(:one), rating: 6, reviewer_name: "Test")
    assert_not review.valid?
    assert_includes review.errors[:rating], "is not included in the list"
  end
end
