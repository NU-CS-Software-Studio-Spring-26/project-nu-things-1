class OwnerLinkMailer < ApplicationMailer
  def lost_item_owner(lost_item)
    @lost_item = lost_item
    @owner_token = lost_item.signed_id(purpose: :owner, expires_in: 30.days)
    @edit_url = edit_lost_item_owner_url(token: @owner_token)

    mail(to: @lost_item.contact_email, subject: "Your private link to edit your lost item post")
  end

  def found_item_owner(found_item)
    @found_item = found_item
    @owner_token = found_item.signed_id(purpose: :owner, expires_in: 30.days)
    @edit_url = edit_found_item_owner_url(token: @owner_token)

    mail(to: @found_item.contact_email, subject: "Your private link to edit your found item post")
  end
end

