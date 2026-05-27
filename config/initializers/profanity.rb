# frozen_string_literal: true

# https://github.com/rameerez/moderate
return unless defined?(Moderate)

Moderate.configure do |config|
  config.error_message = "Please remove inappropriate language from this field."

  extra = ENV.fetch("MODERATE_ADDITIONAL_WORDS", "").split(",").map(&:strip).reject(&:blank?)
  config.additional_words = (config.additional_words + extra).uniq

  excluded = ENV.fetch("MODERATE_EXCLUDED_WORDS", "").split(",").map(&:strip).reject(&:blank?)
  # Northwestern's Henry Crown Sports Pavilion acronym; false-positive on the moderate word list.
  campus_excluded = %w[spac]
  config.excluded_words = (config.excluded_words + campus_excluded + excluded).uniq
end

if Rails.env.test?
  Moderate.configure do |config|
    config.additional_words = (config.additional_words + [ "xxtestbadxx" ]).uniq
  end
end

Rails.application.config.x.profanity_flash_alert = ENV.fetch(
  "PROFANITY_FLASH_ALERT",
  "Please remove inappropriate language and try again."
)
