class LostItem < ApplicationRecord
  STATUSES = %w[open resolved].freeze

  has_many :claims, as: :claimable, dependent: :destroy

  validates :title, :description, :category, :location_lost, :date_lost,
            :contact_name, :contact_email, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :assign_default_status, on: :create

  private

  def assign_default_status
    self.status = "open" if status.blank?
  end
end
