# frozen_string_literal: true

module ExchangeRatingReasons
  extend ActiveSupport::Concern

  REASONS = {
    "communication" => "Communication",
    "timeliness" => "Timeliness",
    "rudeness" => "They were rude",
    "other" => "Other"
  }.freeze

  OTHER_BODY_MAX_LENGTH = 50

  included do
    validates :reason, presence: true, inclusion: { in: REASONS.keys }
    validates :body, length: { maximum: OTHER_BODY_MAX_LENGTH }, allow_blank: true
    validate :other_reason_requires_body
    before_validation :clear_body_unless_other
  end

  def reason_label
    REASONS[reason]
  end

  def reason_summary
    return reason_label unless reason == "other" && body.present?

    "#{reason_label}: #{body}"
  end

  private

  def other_reason_requires_body
    return unless reason == "other"

    errors.add(:body, "can't be blank when Other is selected") if body.to_s.strip.blank?
  end

  def clear_body_unless_other
    self.body = nil unless reason == "other"
  end
end
