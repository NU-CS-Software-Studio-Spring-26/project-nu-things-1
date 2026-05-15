class RentalItem < ApplicationRecord
  include ListingPhotoAttachment
  include ListingTextLimits
  include ModeratedContent

  belongs_to :user, optional: true

  has_many :bookings, dependent: :destroy
  has_many :rental_reviews, dependent: :destroy

  def reviews_count
    rental_reviews.loaded? ? rental_reviews.size : rental_reviews.count
  end

  def average_rating
    if rental_reviews.loaded?
      return nil if rental_reviews.empty?

      rental_reviews.sum(&:rating).to_f / rental_reviews.size
    else
      rental_reviews.average(:rating)&.to_f
    end
  end

  def past_renters_count
    bookings.completed_past.count
  end

  def self.listing_name_attribute
    :owner_name
  end

  CATEGORIES = ListingCategories::VALUES
  CONDITIONS = %w[ Like\ New Good Fair ].freeze
  RENTAL_PERIODS = %w[ per_day per_week per_month ].freeze
  STATUSES = %w[ available rented inactive ].freeze

  moderate_attributes :title, :description, :location

  validates :title, :description, :category, :location, :owner_name, :owner_email, presence: true
  validates :rental_price, presence: true, numericality: { greater_than: 0 }
  validates :rental_period, inclusion: { in: RENTAL_PERIODS }
  validates :condition, inclusion: { in: CONDITIONS }
  validates :category, inclusion: { in: CATEGORIES }
  validates :status, inclusion: { in: STATUSES }
  validates :available_from, :available_to, presence: true
  validates :owner_email, format: { with: URI::MailTo::EMAIL_REGEXP }
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
