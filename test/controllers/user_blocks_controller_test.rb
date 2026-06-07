# frozen_string_literal: true

require "test_helper"

class UserBlocksControllerTest < ActionDispatch::IntegrationTest
  test "user can block another user from conversation context" do
    sign_in_as(users(:admin))

    assert_difference("UserBlock.count", 1) do
      post user_block_path(users(:nu_student))
    end

    assert_redirected_to conversations_url
    assert users(:admin).blocking?(users(:nu_student))
  end

  test "user can unblock another user" do
    sign_in_as(users(:admin))
    users(:admin).block!(users(:nu_student))

    assert_difference("UserBlock.count", -1) do
      delete user_block_path(users(:nu_student))
    end

    assert_redirected_to conversations_url
    assert_not users(:admin).blocking?(users(:nu_student))
  end
end
