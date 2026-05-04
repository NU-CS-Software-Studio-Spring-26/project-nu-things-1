# frozen_string_literal: true

module ListingPhotoAttachment
  extend ActiveSupport::Concern

  MAX_PHOTO_BYTES = 5.megabytes
  ALLOWED_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze

  included do
    has_one_attached :photo
    validate :acceptable_listing_photo
  end

  def listing_image_available?
    photo.attached? || image_url.present?
  end

  private

  def acceptable_listing_photo
    return unless photo.attached?

    unless ALLOWED_TYPES.include?(photo.content_type)
      errors.add(:photo, "must be JPEG, PNG, GIF, or WebP")
    end

    return unless photo.byte_size > MAX_PHOTO_BYTES

    errors.add(:photo, "is too large (maximum is 5 MB)")
  end
end
