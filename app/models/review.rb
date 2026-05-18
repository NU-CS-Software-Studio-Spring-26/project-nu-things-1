# frozen_string_literal: true

class Review < ApplicationRecord
  include ModeratedContent

  SUBJECT_TYPES = %w[Booking].freeze

  belongs_to :reviewer, class_name: "User", inverse_of: :reviews_written
  belongs_to :reviewee, class_name: "User", inverse_of: :reviews_received
  belongs_to :subject, polymorphic: true

  moderate_attributes :body

  before_validation :normalize_rating

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :subject_type, inclusion: { in: SUBJECT_TYPES }
  validates :body, length: { maximum: 2000 }, allow_blank: true
  validates :reviewer_id, uniqueness: { scope: %i[subject_type subject_id], message: "already reviewed this stay" }
  validate :subject_must_allow_review
  validate :reviewer_cannot_equal_reviewee

  private

  def normalize_rating
    self.rating = rating.to_i if rating.present?
  end

  def subject_must_allow_review
    return unless subject_type == "Booking" && subject.is_a?(Booking)

    b = subject
    if b.renter_id != reviewer_id
      errors.add(:base, "You can only leave a review for your own booking.")
      return
    end

    owner = b.rental_item&.user
    if owner.blank?
      errors.add(:base, "This listing has no owner profile to review.")
      return
    end

    if reviewee_id != owner.id
      errors.add(:reviewee_id, "must be the rental owner.")
    end

    return if errors.any?

    unless b.renter_can_leave_review?
      errors.add(:base, "This booking can’t be reviewed yet (or was cancelled).")
    end
  end

  def reviewer_cannot_equal_reviewee
    return if reviewer_id.blank? || reviewee_id.blank?
    return unless reviewer_id == reviewee_id

    errors.add(:base, "You can’t review yourself.")
  end
end
