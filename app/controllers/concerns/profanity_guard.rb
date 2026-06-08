# frozen_string_literal: true

module ProfanityGuard
  extend ActiveSupport::Concern

  private

  def profanity_in?(text)
    defined?(Moderate::Text) && Moderate::Text.bad_words?(text.to_s)
  end

  def redirect_if_profanity!(target, text)
    return false unless profanity_in?(text)

    redirect_to target, alert: profanity_blocked_alert
    true
  end
end
