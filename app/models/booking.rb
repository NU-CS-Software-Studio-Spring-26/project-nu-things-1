# frozen_string_literal: true

class Booking < ApplicationRecord
  include ModeratedContent

  belongs_to :rental_item
  belongs_to :renter, class_name: "User", optional: true

  has_one :renter_review, class_name: "Review", as: :subject, dependent: :destroy, inverse_of: :subject

  STATUSES = [ "pending", "confirmed", "cancelled" ].freeze

  moderate_attributes :notes

  validates :start_date, :end_date, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :end_date_after_start_date
  validate :no_overlapping_bookings
  validate :cannot_book_own_listing

  scope :overlapping, ->(start_date, end_date) {
    where("bookings.start_date <= ? AND bookings.end_date >= ?", end_date, start_date)
  }

  scope :active, -> { where.not(status: "cancelled") }

<<<<<<< Updated upstream
  scope :completed_past, -> {
    where(status: "confirmed").where(end_date: ...Date.current)
  }
=======
  # Renter may leave one review after the booking window ends (MVP: any non-cancelled booking).
  def renter_can_leave_review?
    return false if renter_id.blank?
    return false if rental_item&.user_id.blank?
    return false if status == "cancelled"
    return false unless end_date.present? && end_date < Date.current

    true
  end
>>>>>>> Stashed changes

  private

  def cannot_book_own_listing
    return if renter_id.blank? || rental_item.blank?

    if rental_item.user_id.present? && rental_item.user_id == renter_id
      errors.add(:base, "You can’t book your own listing.")
    end
  end

  def end_date_after_start_date
    return if end_date.blank? || start_date.blank?

    if end_date < start_date
      errors.add(:end_date, "must be after start date")
    end
  end

  def no_overlapping_bookings
    return if start_date.blank? || end_date.blank?

    overlapping = Booking.active
      .where(rental_item_id: rental_item_id)
      .where("bookings.start_date <= ? AND bookings.end_date >= ?", end_date, start_date)
      .where.not(id: id)

    if overlapping.any?
      errors.add(:base, "These dates overlap with an existing booking")
    end
  end
end
