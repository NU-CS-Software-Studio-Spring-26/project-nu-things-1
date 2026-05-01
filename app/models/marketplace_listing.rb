class MarketplaceListing < ApplicationRecord
  LISTING_TYPES = %w[for_sale wanted].freeze
  CATEGORIES = %w[Camping\ Gear Electronics Tools Books Furniture Sports\ Equipment Other].freeze
  STATUSES = %w[active completed inactive].freeze

  validates :title, :description, :category, :location, :contact_name, :contact_email, :listing_type, presence: true
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :listing_type, inclusion: { in: LISTING_TYPES }
  validates :category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }

  validates :price, numericality: { greater_than: 0 }, allow_nil: true
  validate :price_required_for_for_sale
  validate :custom_category_required_for_other

  before_validation :assign_default_status, on: :create

  def category_label
    return category unless category == "Other"
    custom_category.presence || category
  end

  private

  def price_required_for_for_sale
    return unless listing_type == "for_sale"
    if price.blank? || price.to_d <= 0
      errors.add(:price, "must be provided for for-sale listings")
    end
  end

  def custom_category_required_for_other
    return unless category == "Other"
    if custom_category.blank?
      errors.add(:custom_category, "can't be blank when category is Other")
    end
  end

  def assign_default_status
    self.status = "active" if status.blank?
  end
end

