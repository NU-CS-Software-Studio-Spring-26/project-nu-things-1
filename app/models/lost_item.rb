class LostItem < ApplicationRecord
  include ListingAuthorizable
  include ListingPhotoAttachment
  include ListingTextLimits
  include ListableMessaging
  include ModeratedContent

  STATUSES = %w[open resolved].freeze
  CATEGORIES = ListingCategories::VALUES

  belongs_to :user, optional: true

  moderate_attributes :title, :description, :location_lost, :reward, :color, :brand

  validates :title, :description, :category, :location_lost, :date_lost,
            :contact_name, :contact_email, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :category, inclusion: { in: CATEGORIES }
  validates :contact_email, format: { with: User::NORTHWESTERN_EMAIL, message: "must be a Northwestern email (@u.northwestern.edu or @northwestern.edu)" }
  validates :color, :brand, length: { maximum: ListingTextLimits::COLOR_BRAND_MAX_LENGTH }, allow_blank: true
  validates :custom_category, length: { maximum: ListingTextLimits::CUSTOM_CATEGORY_MAX_LENGTH }, allow_blank: true
  validate :custom_category_required_for_other
  validate :validate_lost_location_and_reward_words

  before_validation :assign_default_status, on: :create

  def category_label
    return category unless category == "Other"

    custom_category.presence || category
  end

  private

  def assign_default_status
    self.status = "open" if status.blank?
  end

  def custom_category_required_for_other
    return unless category == "Other"

    errors.add(:custom_category, "can't be blank when category is Other") if custom_category.blank?
  end

  def validate_lost_location_and_reward_words
    validate_words(:location_lost, ListingTextLimits::LOCATION_MAX_WORDS)
    validate_words(:reward, ListingTextLimits::REWARD_MAX_WORDS)
  end
end
