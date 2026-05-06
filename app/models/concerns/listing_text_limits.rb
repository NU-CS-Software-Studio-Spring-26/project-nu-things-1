# frozen_string_literal: true

module ListingTextLimits
  extend ActiveSupport::Concern

  TITLE_MAX_LENGTH = 250
  NAME_MAX_LENGTH = 150
  DESCRIPTION_MAX_WORDS = 100
  COLOR_BRAND_MAX_LENGTH = 50
  CUSTOM_CATEGORY_MAX_LENGTH = 50
  LOCATION_MAX_WORDS = 20
  REWARD_MAX_WORDS = 20

  included do
    validates :title, length: { maximum: TITLE_MAX_LENGTH }
    validate :validate_description_word_limit
    validate :validate_listing_contact_name_length
  end

  class_methods do
    # Rental listings use +owner_name+ instead of +contact_name+.
    def listing_name_attribute
      :contact_name
    end
  end

  private

  def word_count_for(value)
    t = value.to_s.strip
    t.empty? ? 0 : t.split(/\s+/).size
  end

  def validate_words(attribute, max_words)
    n = word_count_for(send(attribute))
    return if n <= max_words

    errors.add(attribute, "must be #{max_words} words or fewer (#{n} words)")
  end

  def validate_description_word_limit
    text = description.to_s.strip
    return if text.blank?

    count = text.split(/\s+/).size
    return if count <= DESCRIPTION_MAX_WORDS

    errors.add(:description, "must be #{DESCRIPTION_MAX_WORDS} words or fewer (#{count} words)")
  end

  def validate_listing_contact_name_length
    attr = self.class.listing_name_attribute
    val = send(attr).to_s
    return if val.blank?

    return if val.length <= NAME_MAX_LENGTH

    errors.add(attr, "is too long (maximum is #{NAME_MAX_LENGTH} characters)")
  end
end
