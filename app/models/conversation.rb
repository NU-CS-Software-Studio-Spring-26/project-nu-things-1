# frozen_string_literal: true

class Conversation < ApplicationRecord
  belongs_to :listable, polymorphic: true
  belongs_to :starter, class_name: "User"

  has_many :conversation_participants, dependent: :destroy
  has_many :participants, through: :conversation_participants, source: :user
  has_many :conversation_messages, dependent: :destroy

  validates :subject, presence: true
  validates :last_message_at, presence: true
  validates :starter_id, uniqueness: { scope: %i[listable_type listable_id] }

  scope :for_user, lambda { |user|
    joins(:conversation_participants)
      .where(conversation_participants: { user_id: user.id })
      .distinct
  }
  scope :recent_first, -> { order(last_message_at: :desc) }

  def participant_record_for(user)
    conversation_participants.find_by!(user: user)
  end

  def unread_for?(user)
    participant = conversation_participants.find_by(user: user)
    return false unless participant

    last_read = participant.last_read_at
    return true if last_read.nil?

    last_message_at > last_read
  end

  def other_participant(current_user)
    participants.where.not(id: current_user.id).first
  end

  def mark_read_for!(user, at: Time.current)
    participant_record_for(user).update!(last_read_at: at)
  end
end
