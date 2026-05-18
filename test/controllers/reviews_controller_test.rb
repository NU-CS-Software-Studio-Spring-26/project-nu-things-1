# frozen_string_literal: true

require "test_helper"

class ReviewsControllerTest < ActionDispatch::IntegrationTest
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
      VALID_RENTAL_PARAMS.merge(title: "Review flow #{SecureRandom.hex(4)}", user: @owner)
    )
    @booking = @item.bookings.create!(
      renter: @renter,
      start_date: Date.new(2026, 7, 10),
      end_date: Date.new(2026, 7, 14),
      status: "pending",
      notes: "Test"
    )
  end

  test "new redirects when not signed in" do
    get new_rental_item_booking_review_url(@item, @booking)
    assert_redirected_to new_session_url
  end

  test "new redirects when rental period not finished" do
    travel_to Date.new(2026, 7, 12) do
      sign_in_as(@renter)
      get new_rental_item_booking_review_url(@item, @booking)
      assert_redirected_to rental_item_url(@item)
    end
  end

  test "new loads when eligible and creates review" do
    travel_to Date.new(2026, 7, 16) do
      sign_in_as(@renter)
      get new_rental_item_booking_review_url(@item, @booking)
      assert_response :success

      assert_difference("Review.count", 1) do
        post rental_item_booking_review_url(@item, @booking), params: {
          review: { rating: 5, body: "Great lender and item." }
        }
      end

      assert_redirected_to rental_item_url(@item)
      rev = Review.last
      assert_equal @renter.id, rev.reviewer_id
      assert_equal @owner.id, rev.reviewee_id
      assert_equal @booking.id, rev.subject_id
      assert_equal "Booking", rev.subject_type
    end
  end

  test "cannot review someone elses booking" do
    travel_to Date.new(2026, 7, 16) do
      sign_in_as(@owner)
      get new_rental_item_booking_review_url(@item, @booking)
      assert_redirected_to rental_item_url(@item)
    end
  end
end
