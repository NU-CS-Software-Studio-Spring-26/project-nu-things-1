# frozen_string_literal: true

require "test_helper"

class BookingExchangeRatingTest < ActiveSupport::TestCase
  setup do
    @rating = booking_exchange_ratings(:owner_rated_renter)
  end

  test "requires a valid reason" do
    @rating.reason = nil
    assert_not @rating.valid?
    assert_includes @rating.errors[:reason], "can't be blank"

    @rating.reason = "invalid"
    assert_not @rating.valid?
    assert_includes @rating.errors[:reason], "is not included in the list"
  end

  test "other reason requires body up to 50 characters" do
    @rating.reason = "other"
    @rating.body = nil
    assert_not @rating.valid?
    assert_includes @rating.errors[:body], "can't be blank when Other is selected"

    @rating.body = "a" * 51
    assert_not @rating.valid?
    assert_includes @rating.errors[:body], "is too long (maximum is 50 characters)"

    @rating.body = "Late and unresponsive."
    assert @rating.valid?
    assert_equal "Other: Late and unresponsive.", @rating.reason_summary
  end

  test "clears body when reason is not other" do
    @rating.reason = "communication"
    @rating.body = "Should be cleared."
    @rating.valid?

    assert_nil @rating.body
  end
end
