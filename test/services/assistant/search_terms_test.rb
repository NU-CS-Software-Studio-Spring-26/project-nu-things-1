# frozen_string_literal: true

require "test_helper"

class Assistant::SearchTermsTest < ActiveSupport::TestCase
  test "strips filler words from natural language queries" do
    terms = Assistant::SearchTerms.extract(
      [ "looking", "for", "tent" ],
      fallback_text: "I am looking for a tent"
    )

    assert_equal [ "tent" ], terms
  end

  test "extracts multiple item keywords" do
    terms = Assistant::SearchTerms.extract(
      [ "black", "north", "face", "backpack" ],
      fallback_text: "black north face backpack"
    )

    assert_includes terms, "black"
    assert_includes terms, "backpack"
  end
end
