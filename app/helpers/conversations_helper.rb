# frozen_string_literal: true

module ConversationsHelper
  def conversation_listable_path(listable)
    case listable
    when LostItem then lost_item_path(listable)
    when FoundItem then found_item_path(listable)
    when RentalItem then rental_item_path(listable)
    when MarketplaceListing then marketplace_listing_path(listable)
    else root_path
    end
  end

  def conversation_listable_type_label(listable)
    return "Listing" unless listable

    listable.messaging_listing_label
  end

  def conversation_participant_name(user)
    return "You" if user == current_user

    user.first_name.presence || display_user_name(user)
  end

  def conversation_preview_text(conversation, viewer)
    message = conversation.conversation_messages.order(created_at: :desc).first
    return "No messages yet" unless message

    prefix = message.sender_id == viewer.id ? "You: " : "#{conversation_participant_name(message.sender)}: "
    body = message.body.to_s
    preview = body.length > 80 ? "#{body[0, 77]}..." : body
    "#{prefix}#{preview}"
  end

  def marketplace_transaction_summary(transaction)
    if transaction.complete?
      "Purchase closed on both sides"
    elsif transaction.buyer_marked_complete? || transaction.seller_marked_complete?
      "Waiting for the other person to confirm"
    else
      "Purchase still open"
    end
  end
end
