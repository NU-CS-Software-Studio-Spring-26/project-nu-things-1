# frozen_string_literal: true

require "test_helper"

class BookingTest < ActiveSupport::TestCase
  test "exchange_complete when both parties marked handoff" do
    booking = bookings(:past_confirmed)
    assert booking.exchange_complete?
  end

  test "can_mark_given only for confirmed booking owner" do
    booking = bookings(:confirmed_awaiting_handoff)
    assert booking.can_confirm?(users(:admin)) == false
    assert booking.can_mark_given?(users(:admin))
    assert_not booking.can_mark_given?(users(:nu_student))
  end

  test "can_mark_received only for renter on confirmed booking" do
    booking = bookings(:confirmed_awaiting_handoff)
    assert booking.can_mark_received?(users(:nu_student))
    assert_not booking.can_mark_received?(users(:admin))
  end

  test "rejects overlapping dates on same rental item" do
    existing = bookings(:future_pending)
    conflict = Booking.new(
      rental_item: existing.rental_item,
      user: users(:admin),
      start_date: existing.start_date,
      end_date: existing.end_date,
      status: "pending"
    )
    assert_not conflict.valid?
    assert conflict.errors[:base].any?
  end
end
