# frozen_string_literal: true

require "test_helper"

class AssistantHelperTest < ActionView::TestCase
  test "formats message time in central time zone" do
    time = Time.find_zone!("Central Time (US & Canada)").local(2026, 6, 6, 19, 55, 0)
    formatted = assistant_message_time(time.iso8601)

    assert_match(/7:55 PM/, formatted)
    assert_match(/CDT|CST/, formatted)
  end
end
