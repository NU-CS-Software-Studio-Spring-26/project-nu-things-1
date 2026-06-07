# frozen_string_literal: true

module ExchangeRatingReasons
  extend ActiveSupport::Concern

  REASONS = {
    "communication" => "Communication",
    "timeliness" => "Timeliness",
    "kindness" => "Kindness",
    "other" => "Other"
  }.freeze

  OTHER_BODY_MAX_LENGTH = 50

  included do
    validates :body, length: { maximum: OTHER_BODY_MAX_LENGTH }, allow_blank: true
    validate :reasons_are_valid
    validate :other_reason_requires_body
    before_validation :normalize_reasons_list
    before_validation :clear_body_unless_other
  end

  def reason_summary
    labels = selected_reasons.map { |reason| REASONS[reason] }
    if other_selected? && body.present?
      labels = labels.map { |label| label == "Other" ? "Other: #{body}" : label }
    end
    labels.join(" · ")
  end

  private

  def selected_reasons
    normalize_reasons(reasons)
  end

  def other_selected?
    selected_reasons.include?("other")
  end

  def normalize_reasons_list
    self.reasons = normalize_reasons(reasons)
  end

  def normalize_reasons(value)
    Array(value).filter_map { |reason| reason.to_s.strip.presence }.uniq
  end

  def reasons_are_valid
    selected = selected_reasons
    if selected.empty?
      errors.add(:reasons, "select at least one")
      return
    end

    invalid = selected - REASONS.keys
    errors.add(:reasons, "includes invalid options") if invalid.any?
  end

  def other_reason_requires_body
    return unless other_selected?

    errors.add(:body, "can't be blank when Other is selected") if body.to_s.strip.blank?
  end

  def clear_body_unless_other
    self.body = nil unless other_selected?
  end
end
