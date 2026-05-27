class Booking < ApplicationRecord
  include ModeratedContent

  belongs_to :rental_item
  belongs_to :user, optional: true, inverse_of: :bookings

  has_many :exchange_ratings, class_name: "BookingExchangeRating", dependent: :destroy

  STATUSES = %w[pending confirmed cancelled].freeze

  moderate_attributes :notes

  validates :start_date, :end_date, presence: true
  validates :status, inclusion: { in: STATUSES }
  validate :end_date_after_start_date
  validate :no_overlapping_bookings

  # Portable date-range overlap (SQLite + PostgreSQL).
  scope :overlapping, ->(range_start, range_end) {
    where("start_date <= ? AND ? <= end_date", range_end, range_start)
  }

  scope :active, -> { where.not(status: "cancelled") }

  scope :completed_past, -> {
    where(status: "confirmed").where(end_date: ...Date.current)
  }

  def owner_user
    rental_item.user
  end

  def exchange_complete?
    pickup_complete? && return_complete?
  end

  def pickup_complete?
    owner_marked_given? && renter_marked_received?
  end

  def return_complete?
    renter_marked_returned? && owner_marked_return_received?
  end

  def owner_marked_given?
    owner_marked_given_at.present?
  end

  def renter_marked_received?
    renter_marked_received_at.present?
  end

  def renter_marked_returned?
    renter_marked_returned_at.present?
  end

  def owner_marked_return_received?
    owner_marked_return_received_at.present?
  end

  def exchange_ratee_for(actor)
    return if actor.blank?

    return owner_user if actor.id == user_id
    return user if actor.id == owner_user&.id
  end

  def exchange_rating_from_to(from_user, to_user, interaction_phase: nil)
    return if from_user.blank? || to_user.blank?

    query = exchange_ratings.where(rater_id: from_user.id, ratee_id: to_user.id)
    query = query.where(interaction_phase: interaction_phase) if interaction_phase.present?
    query.first
  end

  def editable_by_owner?(actor)
    return false if actor.blank?

    rental_item.editable_by?(actor)
  end

  def editable_by_renter?(actor)
    return false if actor.blank?

    user_id.present? && user_id == actor.id
  end

  def can_confirm?(actor)
    status == "pending" && editable_by_owner?(actor)
  end

  def can_mark_given?(actor)
    status == "confirmed" && editable_by_owner?(actor) && !owner_marked_given?
  end

  def can_mark_received?(actor)
    status == "confirmed" && editable_by_renter?(actor) && !renter_marked_received?
  end

  def can_mark_returned?(actor)
    status == "confirmed" && editable_by_renter?(actor) && !renter_marked_returned?
  end

  def can_mark_return_received?(actor)
    status == "confirmed" && editable_by_owner?(actor) && !owner_marked_return_received?
  end

  def can_cancel?(actor)
    return false if actor.blank?
    return false if status == "cancelled"

    can_confirm?(actor) || editable_by_renter?(actor) || actor.admin?
  end

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
      .overlapping(start_date, end_date)
      .where.not(id: id)

    if overlapping.any?
      errors.add(:base, "These dates overlap with an existing booking")
    end
  end
end
