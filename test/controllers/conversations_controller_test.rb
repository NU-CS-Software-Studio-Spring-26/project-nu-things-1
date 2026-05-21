# frozen_string_literal: true

require "test_helper"

class ConversationsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in_as(users(:nu_student))
  end

  test "requires login for index" do
    delete session_path
    get conversations_path
    assert_redirected_to new_session_path
  end

  test "index lists participant conversations" do
    get conversations_path
    assert_response :success
    assert_match "Fixture lost item admin owned", response.body
  end

  test "show marks conversation read for viewer" do
    conversation = conversations(:student_to_admin_lost)
    participant = conversation.conversation_participants.find_by(user: users(:nu_student))
    participant.update!(last_read_at: nil)

    get conversation_path(conversation)
    assert_response :success
    assert participant.reload.last_read_at.present?
  end

  test "cannot view conversation user is not part of" do
    orphan = Conversation.create!(
      listable: lost_items(:two),
      starter: users(:admin),
      subject: "Admin only",
      last_message_at: Time.current
    )
    orphan.conversation_participants.create!(user: users(:admin))

    get conversation_path(orphan)
    assert_response :not_found
  end
end
