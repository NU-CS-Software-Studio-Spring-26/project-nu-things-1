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

  test "posted_by? matches linked user or owner email" do
    owner = users(:nu_student)
    item = RentalItem.create!(
      user: owner,
      title: "Test rental",
      description: "A test rental item for policy checks.",
      category: "Electronics",
      rental_price: 10,
      rental_period: "per_day",
      condition: "Good",
      location: "Evanston campus",
      available_from: Date.new(2026, 5, 1),
      available_to: Date.new(2026, 12, 31),
      owner_name: "Sam Student",
      owner_email: owner.email,
      status: "available"
    )
    assert item.posted_by?(owner)
    assert_not item.posted_by?(users(:admin))
  end

  test "can_leave_review requires available listing and prior message" do
    owner = users(:nu_student)
    reviewer = users(:admin)
    item = RentalItem.create!(
      user: owner,
      title: "Review policy rental",
      description: "Another test rental item for review eligibility.",
      category: "Electronics",
      rental_price: 12,
      rental_period: "per_day",
      condition: "Good",
      location: "North campus",
      available_from: Date.new(2026, 5, 1),
      available_to: Date.new(2026, 12, 31),
      owner_name: "Sam Student",
      owner_email: owner.email,
      status: "available"
    )

    assert_not item.can_leave_review?(reviewer)

    item.conversations.create!(starter: reviewer, subject: "About rental", last_message_at: Time.current)
    assert item.can_leave_review?(reviewer)

    item.update!(status: "rented")
    assert_not item.can_leave_review?(reviewer)
  end
end
