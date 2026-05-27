module BookingsHelper
  def booking_status_badge_class(status)
    case status
    when "pending" then "text-bg-warning"
    when "confirmed" then "text-bg-success"
    when "cancelled" then "text-bg-secondary"
    else "text-bg-light"
    end
  end

  def booking_exchange_summary(booking)
    if booking.exchange_complete?
      "Handoff complete"
    elsif booking.owner_marked_given? && !booking.renter_marked_received?
      "Owner gave item — awaiting renter"
    elsif booking.renter_marked_received? && !booking.owner_marked_given?
      "Renter received item — awaiting owner"
    else
      "Handoff not started"
    end
  end
end
