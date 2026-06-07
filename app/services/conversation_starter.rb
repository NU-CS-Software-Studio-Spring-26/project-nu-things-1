# frozen_string_literal: true

class ConversationStarter
  class Error < StandardError; end
  class OwnerMissing < Error; end
  class SelfMessage < Error; end
  class BlockedUser < Error; end

  def self.start!(listable:, sender:, body:)
    new(listable: listable, sender: sender, body: body).start!
  end

  def initialize(listable:, sender:, body:)
    @listable = listable
    @sender = sender
    @body = body.to_s.strip
  end

  def start!
    owner = @listable.poster_account
    raise OwnerMissing, "poster account" if owner.nil?
    raise SelfMessage, "self" if owner.id == @sender.id
    raise BlockedUser, "blocked" if messaging_blocked_between?(owner, @sender)

    conversation = nil

    Conversation.transaction do
      conversation = Conversation.find_or_initialize_by(
        listable: @listable,
        starter: @sender
      )

      if conversation.new_record?
        conversation.subject = @listable.title.to_s.presence || "Listing inquiry"
        conversation.last_message_at = Time.current
        conversation.save!
        ensure_participants!(conversation, owner, @sender)
      end

      append_message!(conversation)
    end

    conversation
  end

  private

  def messaging_blocked_between?(owner, sender)
    owner.blocking?(sender) || sender.blocking?(owner)
  end

  def ensure_participants!(conversation, owner, sender)
    [ owner, sender ].each do |user|
      conversation.conversation_participants.find_or_create_by!(user: user)
    end
  end

  def append_message!(conversation)
    message = conversation.conversation_messages.build(sender: @sender, body: @body)
    raise ActiveRecord::RecordInvalid, message unless message.valid?

    message.save!
    conversation.update!(last_message_at: message.created_at)
  end
end
