# frozen_string_literal: true

require "test_helper"

class BookingsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rental_item = rental_items(:one)
    @booking = bookings(:confirmed_awaiting_handoff)
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
end
