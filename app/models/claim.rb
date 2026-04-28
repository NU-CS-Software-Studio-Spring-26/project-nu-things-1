class Claim < ApplicationRecord
  STATUSES = %w[requested cancelled completed].freeze

  belongs_to :user
  belongs_to :claimable, polymorphic: true

  validates :status, inclusion: { in: STATUSES }
end

