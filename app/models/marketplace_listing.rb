class MarketplaceListing < ApplicationRecord
  include ListingAuthorizable
  include ListingPhotoAttachment
  include ListingTextLimits
  include ModeratedContent

  belongs_to :user, optional: true

  LISTING_TYPES = %w[for_sale wanted].freeze
  CATEGORIES = ListingCategories::VALUES
  STATUSES = %w[active completed inactive].freeze
  CONDITIONS = [ "Like new", "Lightly used", "Good", "Fair", "Missing parts", "Poor" ].freeze

  moderate_attributes :title, :description, :location, :condition, :custom_category

  validates :title, :description, :category, :location, :contact_name, :contact_email, :listing_type, presence: true
  validates :contact_email, format: { with: User::NORTHWESTERN_EMAIL, message: "must be a Northwestern email (@u.northwestern.edu or @northwestern.edu)" }

  validates :listing_type, inclusion: { in: LISTING_TYPES }
  validates :category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }
  validates :condition, inclusion: { in: CONDITIONS }, allow_blank: true
  validates :custom_category, length: { maximum: ListingTextLimits::CUSTOM_CATEGORY_MAX_LENGTH }, allow_blank: true

  validates :price, numericality: { greater_than: 0 }, allow_nil: true
  validate :price_required_for_for_sale
  validate :custom_category_required_for_other
  validate :validate_marketplace_location_words

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

  def validate_marketplace_location_words
    validate_words(:location, ListingTextLimits::LOCATION_MAX_WORDS)
  end
end
