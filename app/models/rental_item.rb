class RentalItem < ApplicationRecord
  include ListingAuthorizable
  include ListingPhotoAttachment
  requires_listing_photo!
  include ListingTextLimits
  include ListableMessaging
  include BlockableListings
  include ModeratedContent

  belongs_to :user, optional: true

  has_many :bookings, dependent: :destroy
  has_many :conversations, as: :listable, dependent: :destroy
  has_many :rental_reviews, -> { order(created_at: :desc) }, dependent: :destroy

  def reviews_count
    if rental_reviews.loaded?
      rental_reviews.count(&:persisted?)
    else
      rental_reviews.count
    end
  end

  def average_rating
    if rental_reviews.loaded?
      ratings = rental_reviews.select(&:persisted?).map(&:rating)
      return nil if ratings.empty?

      ratings.sum.to_f / ratings.size
    else
      rental_reviews.average(:rating)&.to_f
    end
  end

  def past_renters_count
    bookings.completed_past.count
  end

  def accessible_with_prior_interaction?(viewer)
    return false if viewer.blank?

    bookings.exists?(user_id: viewer.id)
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
    return false unless status == "available"
    return false if posted_by?(user)
    return false if rental_reviews.exists?(user_id: user.id)

    conversations.exists?(starter_id: user.id)
  end

  def self.listing_name_attribute
    :owner_name
  end

  CATEGORIES = ListingCategories::VALUES
  CONDITIONS = %w[ Like\ New Good Fair ].freeze
  RENTAL_PERIODS = %w[ per_day per_week per_month ].freeze
  STATUSES = %w[ available rented inactive ].freeze

  moderate_attributes :title, :description, :location, :owner_name

  validates :title, :description, :category, :location, :owner_name, :owner_email, presence: true
  validates :rental_price, presence: true, numericality: { greater_than: 0 }
  validates :rental_period, inclusion: { in: RENTAL_PERIODS }
  validates :condition, inclusion: { in: CONDITIONS }
  validates :category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }
  validates :available_from, :available_to, presence: true
  validates :owner_email, format: { with: User::NORTHWESTERN_EMAIL, message: "must be a Northwestern email (@u.northwestern.edu or @northwestern.edu)" }
  validate :available_to_after_available_from
  validate :validate_rental_location_words

  before_validation :assign_default_status, on: :create

  private

  def available_to_after_available_from
    return if available_to.blank? || available_from.blank?
    if available_to <= available_from
      errors.add(:available_to, "must be after available_from")
    end
  end

  def validate_rental_location_words
    validate_words(:location, ListingTextLimits::LOCATION_MAX_WORDS)
  end

  def assign_default_status
    self.status = "available" if status.blank?
  end
end
