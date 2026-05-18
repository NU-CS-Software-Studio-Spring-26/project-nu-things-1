# frozen_string_literal: true

# Shared ownership rules for listing models (lost/found/marketplace/rental).
module ListingAuthorizable
  extend ActiveSupport::Concern

  included do
    attr_readonly :user_id
    before_update :prevent_user_id_change
  end

  def editable_by?(user)
    return false if user.blank?

    user.admin? || (user_id.present? && user_id == user.id)
  end

  private

  def prevent_user_id_change
    return unless will_save_change_to_user_id?

    errors.add(:user_id, "cannot be changed")
    throw :abort
  end
end
