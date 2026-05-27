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
      "Pickup and return complete"
    elsif booking.return_complete?
      "Return complete, pickup complete"
    elsif booking.pickup_complete?
      "Pickup complete, return pending"
    else
      "Pickup pending"
    end
  end
end
