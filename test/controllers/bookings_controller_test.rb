# frozen_string_literal: true

require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
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
      VALID_RENTAL_PARAMS.merge(title: "Reviewable tent #{SecureRandom.hex(4)}", user: @owner)
    )
  end

  test "create redirects when not signed in" do
    assert_no_difference("Booking.count") do
      post rental_item_bookings_url(@item), params: {
        booking: { start_date: @item.available_from, end_date: @item.available_from + 2.days, notes: "" }
      }
    end
    assert_redirected_to new_session_url
  end

  test "create assigns renter when signed in" do
    sign_in_as(@renter)
    start_d = @item.available_from + 5.days
    end_d = start_d + 2.days

    assert_difference("Booking.count", 1) do
      post rental_item_bookings_url(@item), params: {
        booking: { start_date: start_d, end_date: end_d, notes: "Thanks" }
      }
    end

    assert_redirected_to rental_item_url(@item)
    b = Booking.last
    assert_equal @renter.id, b.renter_id
  end

  test "create rejects booking own listing" do
    own_item = RentalItem.create!(
      VALID_RENTAL_PARAMS.merge(title: "Own item #{SecureRandom.hex(4)}", user: @renter)
    )
    sign_in_as(@renter)
    start_d = own_item.available_from + 5.days

    assert_no_difference("Booking.count") do
      post rental_item_bookings_url(own_item), params: {
        booking: { start_date: start_d, end_date: start_d + 1.day, notes: "" }
      }
    end

    assert_redirected_to rental_item_url(own_item)
  end
end
