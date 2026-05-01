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
end
