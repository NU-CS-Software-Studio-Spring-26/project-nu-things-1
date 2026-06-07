class MarketplaceListing < ApplicationRecord
  include ListingAuthorizable
  include ListingPhotoAttachment
  requires_listing_photo!
  include ListingTextLimits
  include ListableMessaging
  include BlockableListings
  include ModeratedContent

  belongs_to :user, optional: true

  has_many :conversations, as: :listable, dependent: :destroy
  has_many :marketplace_listing_reviews, -> { order(created_at: :desc) }, dependent: :destroy
  has_many :marketplace_transactions, dependent: :destroy

  def reviews_count
    if marketplace_listing_reviews.loaded?
      marketplace_listing_reviews.count(&:persisted?)
    else
      marketplace_listing_reviews.count
    end
  end

  def average_rating
    if marketplace_listing_reviews.loaded?
      ratings = marketplace_listing_reviews.select(&:persisted?).map(&:rating)
      return nil if ratings.empty?

      ratings.sum.to_f / ratings.size
    else
      marketplace_listing_reviews.average(:rating)&.to_f
    end
  end

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

  def posted_by?(user)
    return false if user.blank?
    return true if user_id.present? && user_id == user.id
    return true if poster_account.present? && poster_account.id == user.id

    email = poster_email_for_messaging
    email.present? && User.normalize_email(email) == User.normalize_email(user.email)
  end

  def can_leave_review?(user)
    return false if user.blank?
    return false unless status == "active"
    return false if posted_by?(user)
    return false if marketplace_listing_reviews.exists?(user_id: user.id)

    conversations.exists?(starter_id: user.id)
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
