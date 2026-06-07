# frozen_string_literal: true

module BlockableListings
  extend ActiveSupport::Concern

  class_methods do
    def visible_to(viewer)
      return all if viewer.blank?

      blocker_ids = UserBlock.where(blocked_id: viewer.id).pluck(:blocker_id)
      return all if blocker_ids.empty?

      blocker_emails = User.where(id: blocker_ids).pluck(:email).filter_map { |email| User.normalize_email(email) }
      email_column = poster_email_column_name
      table = table_name

      return all if email_column.blank?

      where(
        "NOT (#{table}.user_id IN (?) OR LOWER(#{table}.#{email_column}) IN (?))",
        blocker_ids,
        blocker_emails
      )
    end

    def poster_email_column_name
      if column_names.include?("contact_email")
        "contact_email"
      elsif column_names.include?("owner_email")
        "owner_email"
      end
    end
  end

  def visible_to?(viewer)
    return true if viewer.blank?

    poster = poster_account
    return true if poster.blank?

    !poster.blocking?(viewer)
  end

  def viewable_to?(viewer)
    return true if viewer.blank?

    visible_to?(viewer) || accessible_with_prior_interaction?(viewer)
  end

  def accessible_with_prior_interaction?(viewer)
    false
  end
end
