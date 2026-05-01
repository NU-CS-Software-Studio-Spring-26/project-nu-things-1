class ContactsController < ApplicationController
  def create_lost_item_contact
    @lost_item = LostItem.find(params[:lost_item_id])
    sender_name = params[:sender_name]
    sender_email = params[:sender_email]
    message = params[:message]

    if sender_name.present? && sender_email.present? && message.present?
      ContactMailer.lost_item_contact(@lost_item, sender_name, sender_email, message).deliver_later
      redirect_to @lost_item, notice: "Your message has been sent successfully!"
    else
      redirect_to @lost_item, alert: "Please fill in all fields."
    end
  end

  def create_found_item_contact
    @found_item = FoundItem.find(params[:found_item_id])
    sender_name = params[:sender_name]
    sender_email = params[:sender_email]
    message = params[:message]

    if sender_name.present? && sender_email.present? && message.present?
      ContactMailer.found_item_contact(@found_item, sender_name, sender_email, message).deliver_later
      redirect_to @found_item, notice: "Your message has been sent successfully!"
    else
      redirect_to @found_item, alert: "Please fill in all fields."
    end
  end

  def create_rental_item_contact
    @rental_item = RentalItem.find(params[:rental_item_id])
    sender_name = params[:sender_name]
    sender_email = params[:sender_email]
    message = params[:message]

    if sender_name.present? && sender_email.present? && message.present?
      ContactMailer.rental_item_contact(@rental_item, sender_name, sender_email, message).deliver_later
      redirect_to @rental_item, notice: "Your inquiry has been sent successfully!"
    else
      redirect_to @rental_item, alert: "Please fill in all fields."
    end
  end

  def create_marketplace_listing_contact
    @marketplace_listing = MarketplaceListing.find(params[:marketplace_listing_id])
    sender_name = params[:sender_name]
    sender_email = params[:sender_email]
    message = params[:message]

    if sender_name.present? && sender_email.present? && message.present?
      ContactMailer.marketplace_listing_contact(@marketplace_listing, sender_name, sender_email, message).deliver_later
      redirect_to @marketplace_listing, notice: "Your message has been sent successfully!"
    else
      redirect_to @marketplace_listing, alert: "Please fill in all fields."
    end
  end
end
