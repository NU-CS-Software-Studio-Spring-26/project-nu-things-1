# frozen_string_literal: true

# Shared category label display and normalization for all listing types.
module ListingCategoryDisplay
  extend ActiveSupport::Concern

  included do
    before_validation :normalize_listing_category_fields
  end

  def category_label
    ListingCategories.display_label(
      category,
      custom_category: respond_to?(:custom_category) ? custom_category : nil
    )
  end

  private

  def normalize_listing_category_fields
    if category.present?
      canonical = ListingCategories.canonical(category)
      self.category = canonical if canonical
    end

    return unless respond_to?(:custom_category)

    custom = custom_category.to_s.strip
    if category == "Other" && custom.present?
      if (promoted = ListingCategories.canonical(custom))
        self.category = promoted
        self.custom_category = nil
        return
      end

      self.custom_category = ListingCategories.format_custom_label(custom)
    end
  end
end
