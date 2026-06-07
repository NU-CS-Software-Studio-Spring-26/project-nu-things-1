# frozen_string_literal: true

require "test_helper"

class BookingExchangeRatingTest < ActiveSupport::TestCase
  setup do
    @rating = booking_exchange_ratings(:owner_rated_renter)
  end

  test "requires at least one valid reason" do
    @rating.reasons = []
    assert_not @rating.valid?
    assert_includes @rating.errors[:reasons], "select at least one"

    @rating.reasons = [ "invalid" ]
    assert_not @rating.valid?
    assert_includes @rating.errors[:reasons], "includes invalid options"
  end

  test "accepts multiple reasons" do
    @rating.reasons = %w[communication kindness]
    assert @rating.valid?
    assert_equal "Communication · Kindness", @rating.reason_summary
  end

  test "other reason requires body up to 50 characters" do
    @rating.reasons = [ "other" ]
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

  test "clears body when other is not selected" do
    @rating.reasons = [ "communication" ]
    @rating.body = "Should be cleared."
    @rating.valid?

    assert_nil @rating.body
  end
end
