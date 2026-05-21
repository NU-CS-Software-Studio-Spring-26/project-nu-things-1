# frozen_string_literal: true

require "test_helper"

class ListingConversationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:nu_student))
  end

  test "starts conversation from lost item" do
    listing = lost_items(:messaging_target)

    assert_difference -> { Conversation.count }, 1 do
      post lost_item_conversation_path(listing), params: { message: "Interested in this item." }
    end

    conversation = Conversation.order(:id).last
    assert_redirected_to conversation_path(conversation)
    assert_equal "Your message has been sent.", flash[:notice]
  end

  test "rejects profane message" do
    listing = lost_items(:messaging_target)

    assert_no_difference -> { Conversation.count } do
      post lost_item_conversation_path(listing), params: { message: "Hello xxtestbadxx there." }
    end

    assert_redirected_to lost_item_url(listing)
    assert_equal "Please remove inappropriate language and try again.", flash[:alert]
  end

  test "rejects messaging own listing" do
    listing = lost_items(:one)

    assert_no_difference -> { Conversation.count } do
      post lost_item_conversation_path(listing), params: { message: "Hi self" }
    end

    assert_redirected_to lost_item_url(listing)
    assert_match(/cannot message your own listing/i, flash[:alert])
  end
end
