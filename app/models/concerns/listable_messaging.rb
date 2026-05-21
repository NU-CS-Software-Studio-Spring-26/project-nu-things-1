# frozen_string_literal: true

# Resolves the Northwestern account that receives messages about a listing.
module ListableMessaging
  extend ActiveSupport::Concern

  def poster_account
    return user if user_id.present?

    email = poster_email_for_messaging
    return nil if email.blank?

    User.find_by(email: User.normalize_email(email))
  end

  def poster_email_for_messaging
    if respond_to?(:contact_email)
      contact_email
    elsif respond_to?(:owner_email)
      owner_email
    end
  end

  def messaging_listing_label
    self.class.model_name.human
  end
end
