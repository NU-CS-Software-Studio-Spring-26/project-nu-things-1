# frozen_string_literal: true

require "test_helper"

class Assistant::ChatTest < ActiveSupport::TestCase
  setup do
    @listing = lost_items(:one)
    @candidate = Assistant::ListingSearch::Candidate.new(
      key: "lost_item:#{@listing.id}",
      type: "lost_item",
      id: @listing.id,
      title: @listing.title,
      description: @listing.description,
      category: @listing.category,
      location: @listing.location_lost,
      color: "",
      brand: "",
      board_label: "Lost",
      extra: {}
    )
  end

  test "process returns reranked listings" do
    parsed = {
      boards: %w[lost],
      search_terms: [ "fixture" ],
      category: nil,
      marketplace_type: nil,
      intent_summary: "lost item"
    }

    rerank_result = {
      reply: "Found a match.",
      matches: [ { key: @candidate.key, reason: "Looks similar." } ]
    }

    with_stubbed(Assistant::QueryParser, :call, parsed) do
      with_stubbed(Assistant::ListingSearch, :call, [ @candidate ]) do
        with_stubbed(Assistant::Reranker, :call, rerank_result) do
          result = Assistant::Chat.process!(message: "lost fixture item", history: [])

          assert_equal "Found a match.", result.reply
          assert_equal 1, result.listings.size
          assert_equal @listing.title, result.listings.first.title
          assert_includes result.listings.first.path, "/lost_items/"
        end
      end
    end
  end

  test "process rejects blank message" do
    assert_raises(Assistant::Chat::Error) do
      Assistant::Chat.process!(message: "   ", history: [])
    end
  end

  private

  def with_stubbed(mod, method_name, return_value)
    original = mod.method(method_name)
    mod.define_singleton_method(method_name) { |**| return_value }
    yield
  ensure
    mod.define_singleton_method(method_name, original)
  end
end
