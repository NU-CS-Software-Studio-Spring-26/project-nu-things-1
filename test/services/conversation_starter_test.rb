# frozen_string_literal: true

require "test_helper"

class ConversationStarterTest < ActiveSupport::TestCase
  test "creates conversation and message for listing inquiry" do
    listing = lost_items(:messaging_target)
    sender = users(:nu_student)

    assert_difference -> { Conversation.count }, 1 do
      assert_difference -> { ConversationMessage.count }, 1 do
        conversation = ConversationStarter.start!(
          listable: listing,
          sender: sender,
          body: "Hello, is this still available?"
        )

        assert_equal listing, conversation.listable
        assert_equal sender, conversation.starter
        assert_includes conversation.participants, users(:admin)
        assert_includes conversation.participants, sender
      end
    end
  end

  test "reuses conversation for same listing and sender" do
    listing = lost_items(:admin_owned)
    sender = users(:nu_student)
    existing = conversations(:student_to_admin_lost)
    baseline_messages = existing.conversation_messages.count

    first = ConversationStarter.start!(listable: listing, sender: sender, body: "First message")
    second = ConversationStarter.start!(listable: listing, sender: sender, body: "Follow-up question")

    assert_equal existing.id, first.id
    assert_equal existing.id, second.id
    assert_equal baseline_messages + 2, second.conversation_messages.count
  end

  test "raises when messaging a user who blocked the sender" do
    listing = lost_items(:admin_owned)
    sender = users(:nu_student)
    users(:admin).block!(sender)

    assert_raises(ConversationStarter::BlockedUser) do
      ConversationStarter.start!(listable: listing, sender: sender, body: "Hi")
    end
  end

  test "raises when messaging own listing" do
    listing = lost_items(:one)
    sender = users(:nu_student)

    assert_raises(ConversationStarter::SelfMessage) do
      ConversationStarter.start!(listable: listing, sender: sender, body: "Hi")
    end
  end
end
