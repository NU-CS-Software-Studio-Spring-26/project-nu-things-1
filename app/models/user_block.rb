# frozen_string_literal: true

class UserBlock < ApplicationRecord
  belongs_to :blocker, class_name: "User"
  belongs_to :blocked, class_name: "User"

  validates :blocked_id, uniqueness: { scope: :blocker_id }
  validate :cannot_block_self

  private

  def cannot_block_self
    return if blocker_id.blank? || blocked_id.blank?
    return unless blocker_id == blocked_id

    errors.add(:blocked, "cannot be the same as the blocker")
  end
end
