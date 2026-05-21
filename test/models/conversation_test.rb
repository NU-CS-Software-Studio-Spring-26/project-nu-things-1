# frozen_string_literal: true

require "test_helper"

class ConversationTest < ActiveSupport::TestCase
  test "unread when participant has not read since last message" do
    conversation = conversations(:student_to_admin_lost)
    admin = users(:admin)

    assert conversation.unread_for?(admin)
    refute conversation.unread_for?(users(:nu_student))
  end

  test "poster_account resolves user on listing" do
    item = lost_items(:one)
    assert_equal users(:nu_student), item.poster_account
  end

  test "poster_account resolves by contact email when user_id blank" do
    item = lost_items(:messaging_target)

    assert_nil item.user_id
    assert_equal users(:admin), item.poster_account
  end
end
