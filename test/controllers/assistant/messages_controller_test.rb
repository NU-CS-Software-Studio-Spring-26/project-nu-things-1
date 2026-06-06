# frozen_string_literal: true

require "test_helper"

class Assistant::MessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:nu_student)
    @original_key = Rails.application.config.x.gemini_api_key
    Rails.application.config.x.gemini_api_key = "test-key"
    Rails.cache.delete("assistant_chat/v1/user/#{@user.id}")
  end

  teardown do
    Rails.application.config.x.gemini_api_key = @original_key
    Rails.cache.delete("assistant_chat/v1/user/#{@user.id}")
  end

  test "requires sign in" do
    post assistant_messages_url, params: { message: "lost backpack" }
    assert_redirected_to new_session_path
  end

  test "rejects blank message" do
    sign_in_as @user
    post assistant_messages_url, params: { message: "   " }
    assert_redirected_to assistant_url
    assert_match(/enter a message/i, flash[:alert].to_s)
  end

  test "creates assistant reply with stubbed chat service" do
    sign_in_as @user

    listing = Assistant::Chat::ListingResult.new(
      key: "lost_item:1",
      type: "lost_item",
      id: 1,
      title: "Test listing",
      board_label: "Lost",
      reason: "Match",
      path: "/lost_items/1",
      category: "Electronics",
      location: "Library"
    )

    result = Assistant::Chat::Result.new(reply: "Here is a match.", listings: [ listing ])
    original = Assistant::Chat.method(:process!)
    Assistant::Chat.define_singleton_method(:process!) { |**| result }

    post assistant_messages_url, params: { message: "lost phone" }
    assert_redirected_to assistant_url

    follow_redirect!
    assert_response :success
    assert_select ".nu-message-bubble", minimum: 2
    assert_match(/lost phone/i, response.body)
    assert_match(/Here is a match/i, response.body)
    assert_match(/Test listing/i, response.body)
  ensure
    Assistant::Chat.define_singleton_method(:process!, original)
  end

  test "redirects when gemini is not configured" do
    Rails.application.config.x.gemini_api_key = nil
    sign_in_as @user

    post assistant_messages_url, params: { message: "lost phone" }
    assert_redirected_to assistant_url
    assert_match(/not configured/i, flash[:alert].to_s)
  end
end
