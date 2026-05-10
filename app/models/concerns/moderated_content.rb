# frozen_string_literal: true

# Wraps the +moderate+ gem (+validates ..., moderate: true+) for listing-style models.
module ModeratedContent
  extend ActiveSupport::Concern

  class_methods do
    def moderate_attributes(*names)
      names.flatten.each do |name|
        validates name, moderate: true
      end
    end
  end
end
