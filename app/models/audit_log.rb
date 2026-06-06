# frozen_string_literal: true

class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true, optional: true

  validates :action, :subject, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
