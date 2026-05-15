require "test_helper"

class RentalItemTest < ActiveSupport::TestCase
  test "average_rating and reviews_count from reviews" do
    item = rental_items(:one)
    assert_equal 2, item.reviews_count
    assert_in_delta 4.0, item.average_rating, 0.01
  end

  test "past_renters_count counts confirmed bookings that ended before today" do
    item = rental_items(:one)
    travel_to Date.new(2026, 5, 15) do
      assert_equal 1, item.past_renters_count
    end
  end

  test "no reviews yields nil average and zero count" do
    item = rental_items(:two)
    assert_equal 0, item.reviews_count
    assert_nil item.average_rating
    assert_equal 0, item.past_renters_count
  end
end
