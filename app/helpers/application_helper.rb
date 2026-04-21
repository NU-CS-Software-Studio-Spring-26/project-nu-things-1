module ApplicationHelper
  def lost_status_badge_class(status)
    case status
    when "open" then "text-bg-warning"
    when "resolved" then "text-bg-success"
    else "text-bg-secondary"
    end
  end

  def found_status_badge_class(status)
    case status
    when "unclaimed" then "text-bg-info"
    when "claimed" then "text-bg-secondary"
    else "text-bg-secondary"
    end
  end
end
