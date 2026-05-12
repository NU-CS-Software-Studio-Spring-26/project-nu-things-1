# frozen_string_literal: true

# Wraps the +moderate+ gem (+validates ..., moderate: true+) for listing-style models.
# Skips moderation validation gracefully when the gem is unavailable (e.g. Windows dev).
module ModeratedContent
  extend ActiveSupport::Concern

  class_methods do
    def moderate_attributes(*names)
      return unless defined?(Moderate)

      names.flatten.each do |name|
        validates name, moderate: true
      end
    end
  end
end
