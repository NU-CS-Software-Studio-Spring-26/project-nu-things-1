class ContactMailer < ApplicationMailer
  default from: "noreply@northwesternlostfound.com"

  def lost_item_contact(lost_item, sender_name, sender_email, message)
    @lost_item = lost_item
    @sender_name = sender_name
    @sender_email = sender_email
    @message = message

    mail(to: @lost_item.contact_email, subject: "Someone is interested in your lost item: #{@lost_item.title}")
  end

  def found_item_contact(found_item, sender_name, sender_email, message)
    @found_item = found_item
    @sender_name = sender_name
    @sender_email = sender_email
    @message = message

    mail(to: @found_item.contact_email, subject: "Someone is interested in your found item: #{@found_item.title}")
  end

  def rental_item_contact(rental_item, sender_name, sender_email, message)
    @rental_item = rental_item
    @sender_name = sender_name
    @sender_email = sender_email
    @message = message

    mail(to: @rental_item.owner_email, subject: "Rental inquiry for: #{@rental_item.title}")
  end

  def marketplace_listing_contact(marketplace_listing, sender_name, sender_email, message)
    @marketplace_listing = marketplace_listing
    @sender_name = sender_name
    @sender_email = sender_email
    @message = message

    mail(to: @marketplace_listing.contact_email, subject: "Marketplace message about: #{@marketplace_listing.title}")
  end

  def lost_item_report(lost_item, reporter_name, reporter_email, details)
    @lost_item = lost_item
    @reporter_name = reporter_name
    @reporter_email = reporter_email
    @details = details

    mail(
      to: listing_moderation_to,
      reply_to: reporter_email,
      subject: "[NU Things] Reported lost item ##{lost_item.id}: #{lost_item.title}"
    )
  end

  def found_item_report(found_item, reporter_name, reporter_email, details)
    @found_item = found_item
    @reporter_name = reporter_name
    @reporter_email = reporter_email
    @details = details

    mail(
      to: listing_moderation_to,
      reply_to: reporter_email,
      subject: "[NU Things] Reported found item ##{found_item.id}: #{found_item.title}"
    )
  end

  private

  def listing_moderation_to
    Rails.application.config.x.admin_email.presence || "admin@u.northwestern.edu"
  end
end
