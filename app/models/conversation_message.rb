# frozen_string_literal: true

class ConversationMessage < ApplicationRecord
  include ModeratedContent

  BODY_MAX_LENGTH = 2000

  belongs_to :conversation
  belongs_to :sender, class_name: "User"

  moderate_attributes :body

  validates :body, presence: true, length: { maximum: BODY_MAX_LENGTH }
end
