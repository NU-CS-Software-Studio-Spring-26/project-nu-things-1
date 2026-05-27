# frozen_string_literal: true

class BookingExchangeRating < ApplicationRecord
  INTERACTION_PHASES = %w[pickup return].freeze

  belongs_to :booking

  belongs_to :rater, class_name: "User"
  belongs_to :ratee, class_name: "User"

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :rating, numericality: { only_integer: true }
  validates :body, length: { maximum: 600 }, allow_blank: true
  validates :interaction_phase, presence: true, inclusion: { in: INTERACTION_PHASES }

  validates :rater_id, uniqueness: { scope: [ :booking_id, :ratee_id, :interaction_phase ] }
  validate :participants_match_booking
  validate :booking_exchange_completed
  validate :cannot_rate_self

  private

  def participants_match_booking
    return if booking.blank? || rater.blank? || ratee.blank?

    owner_id = booking.owner_user&.id
    renter_id = booking.user_id
    allowed = [ owner_id, renter_id ].compact

    unless allowed.include?(rater_id) && allowed.include?(ratee_id)
      errors.add(:base, "Rater and ratee must both belong to this booking exchange")
    end
  end

  def booking_exchange_completed
    return if booking.blank?
    if interaction_phase == "pickup"
      return if booking.pickup_complete?
    elsif interaction_phase == "return"
      return if booking.return_complete?
    end

    errors.add(:booking, "must be complete for this interaction before ratings are submitted")
  end

  def cannot_rate_self
    return if rater_id.blank? || ratee_id.blank?
    return unless rater_id == ratee_id

    errors.add(:ratee, "cannot be the same as the rater")
  end
end

