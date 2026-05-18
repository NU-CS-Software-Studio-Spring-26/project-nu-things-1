# frozen_string_literal: true

require "test_helper"

class ReviewTest < ActiveSupport::TestCase
  VALID_RENTAL_PARAMS = {
    title: "Camping tent",
    description: "Two-person tent for weekend trips.",
    category: "Camping Gear",
    rental_price: 18,
    rental_period: "per_day",
    condition: "Good",
    location: "Evanston near campus",
    available_from: Date.new(2026, 6, 1),
    available_to: Date.new(2026, 9, 1),
    owner_name: "Test Owner",
    owner_email: "owner@u.northwestern.edu",
    deposit_required: 20,
    status: "available"
  }.freeze

  setup do
    @owner = users(:admin)
    @renter = users(:nu_student)
    @item = RentalItem.create!(
      VALID_RENTAL_PARAMS.merge(title: "Model review #{SecureRandom.hex(4)}", user: @owner)
    )
    @booking = @item.bookings.create!(
      renter: @renter,
      start_date: Date.new(2026, 1, 5),
      end_date: Date.new(2026, 1, 8),
      status: "pending",
      notes: "x"
    )
  end

  test "valid renter review after stay" do
    rev = Review.new(
      reviewer: @renter,
      reviewee: @owner,
      subject: @booking,
      rating: 4,
      body: "Good experience"
    )
    assert rev.valid?
    assert rev.save
  end

  test "rejects wrong reviewee" do
    other = User.create!(
      email: "other-review-test@u.northwestern.edu",
      first_name: "O",
      provider: "google_oauth2",
      uid: "test-other-#{SecureRandom.hex(4)}"
    )
    rev = Review.new(
      reviewer: @renter,
      reviewee: other,
      subject: @booking,
      rating: 4
    )
    assert_not rev.valid?
  end
end
