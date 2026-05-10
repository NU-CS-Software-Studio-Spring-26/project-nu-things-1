class RentalItem < ApplicationRecord
  include ListingPhotoAttachment

  belongs_to :user, optional: true

  has_many :bookings, dependent: :destroy

  CATEGORIES = %w[ Camping\ Gear Electronics Tools Books Furniture Sports\ Equipment Other ].freeze
  CONDITIONS = %w[ Like\ New Good Fair ].freeze
  RENTAL_PERIODS = %w[ per_day per_week per_month ].freeze
  STATUSES = %w[ available rented inactive ].freeze

  validates :title, :description, :category, :location, :owner_name, :owner_email, presence: true
  validates :rental_price, presence: true, numericality: { greater_than: 0 }
  validates :rental_period, inclusion: { in: RENTAL_PERIODS }
  validates :condition, inclusion: { in: CONDITIONS }
  validates :category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }
  validates :available_from, :available_to, presence: true
  validates :owner_email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validate :available_to_after_available_from

  before_validation :assign_default_status, on: :create

  private

  def available_to_after_available_from
    return if available_to.blank? || available_from.blank?
    if available_to <= available_from
      errors.add(:available_to, "must be after available_from")
    end
  end

  def assign_default_status
    self.status = "available" if status.blank?
  end
end
