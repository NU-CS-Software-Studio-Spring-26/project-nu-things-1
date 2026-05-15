class RentalReview < ApplicationRecord
  include ModeratedContent

  belongs_to :rental_item
  belongs_to :user, optional: true

  moderate_attributes :body, :reviewer_name

  validates :rating, presence: true, inclusion: { in: 1..5, only_integer: true }
  validates :reviewer_name, presence: true, if: -> { user_id.blank? }
  validates :user_id, uniqueness: { scope: :rental_item_id }, allow_nil: true

  before_validation :assign_reviewer_name_from_user

  private

  def assign_reviewer_name_from_user
    return if reviewer_name.present? || user.blank?

    self.reviewer_name = user.first_name.to_s.strip.presence || user.email.to_s.split("@").first
  end
end
