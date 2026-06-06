# frozen_string_literal: true

module AssistantHelper
  def assistant_message_time(iso8601)
    return "" if iso8601.blank?

    time = Time.zone.parse(iso8601.to_s)
    return "" unless time

    time.strftime("%-l:%M %p %Z")
  end
end
