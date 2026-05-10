class FoundItem < ApplicationRecord
  include ListingPhotoAttachment
  include ModeratedContent

  STATUSES = %w[unclaimed claimed].freeze

  belongs_to :user, optional: true
  belongs_to :claimed_by_user, class_name: "User", optional: true

  moderate_attributes :title, :description, :location_found, :storage_location, :color, :brand

  validates :title, :description, :category, :location_found, :date_found,
            :contact_name, :contact_email, :status, presence: true
  validates :status, inclusion: { in: STATUSES }
  validates :contact_email, format: { with: URI::MailTo::EMAIL_REGEXP }

  before_validation :assign_default_status, on: :create

  private

  def assign_default_status
    self.status = "unclaimed" if status.blank?
  end
end
