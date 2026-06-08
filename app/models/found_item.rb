class FoundItem < ApplicationRecord
  include ListingAuthorizable
  include ListingPhotoAttachment
  requires_listing_photo!
  include ListingTextLimits
  include ListableMessaging
  include BlockableListings
  include ModeratedContent

  STATUSES = %w[unclaimed claimed].freeze
  CATEGORIES = ListingCategories::VALUES

  belongs_to :user, optional: true
  belongs_to :claimed_by_user, class_name: "User", optional: true

  moderate_attributes :title, :description, :location_found, :storage_location, :color, :brand, :custom_category

  validates :title, :description, :category, :location_found, :date_found,
            :contact_name, :contact_email, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :category, inclusion: { in: CATEGORIES }
  validates :contact_email, format: { with: User::NORTHWESTERN_EMAIL, message: "must be a Northwestern email (@u.northwestern.edu or @northwestern.edu)" }
  validates :color, :brand, length: { maximum: ListingTextLimits::COLOR_BRAND_MAX_LENGTH }, allow_blank: true
  validates :custom_category, length: { maximum: ListingTextLimits::CUSTOM_CATEGORY_MAX_LENGTH }, allow_blank: true
  validate :custom_category_required_for_other
  validate :validate_found_location_word_limits

  before_validation :assign_default_status, on: :create

  def category_label
    return category unless category == "Other"

    custom_category.presence || category
  end

  private

  def assign_default_status
    self.status = "unclaimed" if status.blank?
  end

  def custom_category_required_for_other
    return unless category == "Other"

    errors.add(:custom_category, "can't be blank when category is Other") if custom_category.blank?
  end

  def validate_found_location_word_limits
    validate_words(:location_found, ListingTextLimits::LOCATION_MAX_WORDS)
    validate_words(:storage_location, ListingTextLimits::LOCATION_MAX_WORDS)
  end
end
