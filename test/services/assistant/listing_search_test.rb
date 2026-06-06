# frozen_string_literal: true

require "test_helper"

class Assistant::ListingSearchTest < ActiveSupport::TestCase
  test "finds lost items matching search terms" do
    item = lost_items(:one)

    parsed = {
      boards: %w[lost],
      search_terms: [ item.title.split.first.downcase ],
      category: nil,
      marketplace_type: nil,
      intent_summary: "lost item"
    }

    candidates = Assistant::ListingSearch.call(parsed: parsed, limit: 10)
    keys = candidates.map(&:key)

    assert_includes keys, "lost_item:#{item.id}"
  end

  test "scopes found board to unclaimed items" do
    claimed = found_items(:two)
    assert_equal "claimed", claimed.status

    parsed = {
      boards: %w[found],
      search_terms: [ claimed.title.split.first.downcase ],
      category: nil,
      marketplace_type: nil,
      intent_summary: "found item"
    }

    candidates = Assistant::ListingSearch.call(parsed: parsed, limit: 10)
    keys = candidates.map(&:key)

    assert_not_includes keys, "found_item:#{claimed.id}"
  end

  test "respects candidate limit" do
    parsed = {
      boards: %w[lost found rentals marketplace],
      search_terms: [ "fixture" ],
      category: nil,
      marketplace_type: nil,
      intent_summary: "anything"
    }

    candidates = Assistant::ListingSearch.call(parsed: parsed, limit: 3)
    assert_operator candidates.size, :<=, 3
  end
end
