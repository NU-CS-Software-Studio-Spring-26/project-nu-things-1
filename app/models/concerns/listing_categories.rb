# frozen_string_literal: true

# Shared category values for lost, found, rental, and marketplace listings.
module ListingCategories
  VALUES = %w[Book Camping\ Gear Electronics Furniture Tools Sports\ Equipment Accessories Other].freeze

  LOST_FOUND_FILTER_EXCLUDED = [
    "Book",
    "Camping Gear",
    "School supplies",
    "Wallets"
  ].freeze

  SLUGS = {
    "Book" => "books",
    "Camping Gear" => "camping-gear",
    "Electronics" => "electronics",
    "Furniture" => "furniture",
    "Tools" => "tools",
    "Sports Equipment" => "sports-equipment",
    "Accessories" => "accessories",
    "Other" => "other"
  }.freeze

  def self.canonical(value)
    str = value.to_s.strip
    return nil if str.blank?

    VALUES.find { |candidate| candidate.casecmp?(str) }
  end

  def self.display_label(category, custom_category: nil)
    cat = canonical(category) || category.to_s.strip
    return cat unless cat == "Other"

    custom = custom_category.to_s.strip
    return "Other" if custom.blank?

    canonical(custom) || format_custom_label(custom)
  end

  def self.format_custom_label(label)
    label.to_s.split(/\s+/).map do |word|
      if word.match?(/\A[A-Z0-9&]+\z/) && word.length <= 4
        word
      else
        word.capitalize
      end
    end.join(" ")
  end

  def self.slug(category)
    cat = canonical(category) || category.to_s.strip
    SLUGS[cat] || cat.parameterize.presence || "other"
  end
end
