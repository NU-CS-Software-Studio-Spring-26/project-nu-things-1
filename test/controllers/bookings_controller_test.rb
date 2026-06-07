# frozen_string_literal: true

require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rental_item = rental_items(:one)
    @booking = bookings(:confirmed_awaiting_handoff)
    @exchange_booking = bookings(:past_confirmed)
  end

  test "blocked renter cannot create new booking" do
    users(:admin).block!(users(:nu_student))
    sign_in_as(users(:nu_student))

    assert_no_difference("Booking.count") do
      post rental_item_bookings_path(@rental_item), params: {
        booking: { start_date: "2026-08-01", end_date: "2026-08-03", notes: "Hi" }
      }
    end

    assert_redirected_to rental_items_url
    assert_equal "You can't request bookings from this owner.", flash[:alert]
  end

  test "create requires sign in" do
    assert_no_difference("Booking.count") do
      post rental_item_bookings_path(@rental_item), params: {
        booking: { start_date: "2026-07-01", end_date: "2026-07-03", notes: "Hi" }
      }
    end
    assert_redirected_to new_session_url
  end

  test "owner can confirm pending booking" do
    pending = bookings(:future_pending)
    sign_in_as(users(:admin))
    patch confirm_rental_item_booking_path(@rental_item, pending)
    assert_redirected_to rental_item_url(@rental_item)
    assert_equal "confirmed", pending.reload.status
  end

  test "owner can mark given on confirmed booking" do
    sign_in_as(users(:admin))
    patch mark_given_rental_item_booking_path(@rental_item, @booking)
    assert_redirected_to rental_item_url(@rental_item)
    assert @booking.reload.owner_marked_given?
  end

  test "renter can mark received on confirmed booking" do
    sign_in_as(users(:nu_student))
    patch mark_received_rental_item_booking_path(@rental_item, @booking)
    assert_redirected_to rental_item_url(@rental_item)
    assert @booking.reload.renter_marked_received?
  end

  test "renter cannot mark given" do
    sign_in_as(users(:nu_student))
    patch mark_given_rental_item_booking_path(@rental_item, @booking)
    assert_redirected_to rental_item_url(@rental_item)
    assert_nil @booking.reload.owner_marked_given_at
  end

  test "renter can mark returned and owner can mark received back" do
    sign_in_as(users(:nu_student))
    patch mark_returned_rental_item_booking_path(@rental_item, @booking)
    assert_redirected_to rental_item_url(@rental_item)
    assert @booking.reload.renter_marked_returned?

    sign_in_as(users(:admin))
    patch mark_return_received_rental_item_booking_path(@rental_item, @booking)
    assert_redirected_to rental_item_url(@rental_item)
    assert @booking.reload.owner_marked_return_received?
  end

  test "owner can rate renter for pickup after pickup complete" do
    sign_in_as(users(:admin))
    @booking.update!(owner_marked_given_at: Time.current, renter_marked_received_at: Time.current)

    assert_difference("BookingExchangeRating.count", 1) do
      post rate_exchange_rental_item_booking_path(@rental_item, @booking, phase: "pickup"), params: {
        exchange_rating: { rating: 5, body: "Easy pickup and return." }
      }
    end

    rating = BookingExchangeRating.order(:id).last
    assert_equal users(:admin), rating.rater
    assert_equal users(:nu_student), rating.ratee
    assert_equal "pickup", rating.interaction_phase
    assert_equal 5, rating.rating
  end

  test "renter can rate owner for return after return complete" do
    sign_in_as(users(:nu_student))
    @booking.update!(renter_marked_returned_at: Time.current, owner_marked_return_received_at: Time.current)

    assert_difference("BookingExchangeRating.count", 1) do
      post rate_exchange_rental_item_booking_path(@rental_item, @booking, phase: "return"), params: {
        exchange_rating: { rating: 4, body: "Great communication." }
      }
    end

    rating = BookingExchangeRating.order(:id).last
    assert_equal users(:nu_student), rating.rater
    assert_equal users(:admin), rating.ratee
    assert_equal "return", rating.interaction_phase
    assert_equal 4, rating.rating
  end

  test "user cannot rate same phase twice for one booking" do
    sign_in_as(users(:admin))

    post rate_exchange_rental_item_booking_path(@rental_item, @exchange_booking, phase: "pickup"), params: {
      exchange_rating: { rating: 5, body: "First rating." }
    }
    assert_redirected_to rental_item_url(@rental_item)

    assert_no_difference("BookingExchangeRating.count") do
      post rate_exchange_rental_item_booking_path(@rental_item, @exchange_booking, phase: "pickup"), params: {
        exchange_rating: { rating: 3, body: "Second rating should not save." }
      }
    end
    assert_redirected_to rental_item_url(@rental_item)
  end

  test "non-participant cannot rate exchange" do
    outsider = User.create!(
      email: "outsider@u.northwestern.edu",
      first_name: "Outsider",
      provider: "google_oauth2",
      uid: "outsider-uid"
    )
    sign_in_as(outsider)

    assert_no_difference("BookingExchangeRating.count") do
      post rate_exchange_rental_item_booking_path(@rental_item, @exchange_booking, phase: "pickup"), params: {
        exchange_rating: { rating: 5, body: "Should fail." }
      }
    end
    assert_redirected_to rental_item_url(@rental_item)
  end
end
