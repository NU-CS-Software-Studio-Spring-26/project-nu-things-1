class MarketplaceListing < ApplicationRecord
  LISTING_TYPES = %w[for_sale wanted].freeze
  CATEGORIES = %w[Camping\ Gear Electronics Tools Books Furniture Sports\ Equipment Other].freeze
  CONDITIONS = %w[Like\ New Good Fair].freeze
  STATUSES = %w[active completed inactive].freeze

  validates :title, :description, :category, :location, :contact_name, :contact_email, :listing_type, presence: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :listing_type, inclusion: { in: LISTING_TYPES }
  validates :condition, inclusion: { in: CONDITIONS }, allow_blank: true
  validates :category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }

  validates :price, numericality: { greater_than: 0 }, allow_nil: true
  validate :price_required_for_for_sale

  before_validation :assign_default_status, on: :create

  private

  def price_required_for_for_sale
    return unless listing_type == "for_sale"
    if price.blank? || price.to_d <= 0
      errors.add(:price, "must be provided for for-sale listings")
    end
  end

  def assign_default_status
    self.status = "active" if status.blank?
  end
end

