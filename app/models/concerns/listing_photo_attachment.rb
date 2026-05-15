# frozen_string_literal: true

module ListingPhotoAttachment
  extend ActiveSupport::Concern

  MAX_PHOTO_BYTES = 5.megabytes
  MAX_PHOTO_MB = (MAX_PHOTO_BYTES / 1.megabyte).to_i
  ALLOWED_TYPES = %w[image/jpeg image/png image/gif image/webp].freeze
  ALLOWED_TYPES_DISPLAY = "JPEG, PNG, GIF, or WebP".freeze

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

    # Validate file type
    unless ALLOWED_TYPES.include?(photo.content_type)
      errors.add(:photo, "must be #{ALLOWED_TYPES_DISPLAY}")
      return
    end

    # Validate file size
    if photo.byte_size > MAX_PHOTO_BYTES
      file_size_mb = (photo.byte_size / 1.megabyte).round(2)
      errors.add(:photo, "is too large (#{file_size_mb} MB). Maximum allowed size is #{MAX_PHOTO_MB} MB.")
    end
  end
end
