class Booking < ApplicationRecord
  include ModeratedContent

  belongs_to :rental_item

  STATUSES = [ "pending", "confirmed", "cancelled" ].freeze

  moderate_attributes :notes

  validates :start_date, :end_date, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :end_date_after_start_date
  validate :no_overlapping_bookings

  scope :overlapping, ->(start_date, end_date) {
    where("(start_date, end_date) OVERLAPS (?, ?)", start_date, end_date)
  }

  scope :active, -> { where.not(status: "cancelled") }

  scope :completed_past, -> {
    where(status: "confirmed").where(end_date: ...Date.current)
  }

  private

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
      .where("(start_date, end_date) OVERLAPS (?, ?)", start_date, end_date)
      .where.not(id: id)

    if overlapping.any?
      errors.add(:base, "These dates overlap with an existing booking")
    end
  end
end
