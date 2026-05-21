# frozen_string_literal: true

require "test_helper"

class ConversationMessagesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @conversation = conversations(:student_to_admin_lost)
    sign_in_as(users(:admin))
  end

  test "participant can reply" do
    assert_difference -> { @conversation.conversation_messages.count }, 1 do
      post conversation_messages_path(@conversation),
           params: { conversation_message: { body: "Yes, still available." } }
    end

    assert_redirected_to conversation_path(@conversation)
  end

  test "rejects profane reply" do
    assert_no_difference -> { @conversation.conversation_messages.count } do
      post conversation_messages_path(@conversation),
           params: { conversation_message: { body: "xxtestbadxx" } }
    end

    assert_response :unprocessable_entity
  end
end
