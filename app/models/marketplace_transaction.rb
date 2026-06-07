# frozen_string_literal: true

class MarketplaceTransaction < ApplicationRecord
  class InvalidConversation < StandardError; end

  belongs_to :conversation
  belongs_to :marketplace_listing
  belongs_to :buyer, class_name: "User"
  belongs_to :seller, class_name: "User"

  has_many :exchange_ratings, class_name: "MarketplaceExchangeRating", dependent: :destroy

  validate :participants_match_conversation

  def self.find_or_create_for!(conversation)
    listing = conversation.listable
    raise InvalidConversation unless listing.is_a?(MarketplaceListing)

    buyer, seller = roles_for(conversation, listing)
    raise InvalidConversation if buyer.blank? || seller.blank?

    find_or_create_by!(conversation: conversation) do |transaction|
      transaction.marketplace_listing = listing
      transaction.buyer = buyer
      transaction.seller = seller
    end
  end

  def self.roles_for(conversation, listing = conversation.listable)
    poster = listing.poster_account
    return [ nil, nil ] if poster.blank?

    other = conversation.participants.find { |participant| participant.id != poster.id }
    return [ nil, nil ] if other.blank?

    if listing.listing_type == "for_sale"
      [ other, poster ]
    else
      [ poster, other ]
    end
  end

  def complete?
    buyer_marked_complete_at.present? && seller_marked_complete_at.present?
  end

  def buyer_marked_complete?
    buyer_marked_complete_at.present?
  end

  def seller_marked_complete?
    seller_marked_complete_at.present?
  end

  def exchange_ratee_for(actor)
    return if actor.blank?

    return seller if actor.id == buyer_id
    buyer if actor.id == seller_id
  end

  def exchange_rating_from_to(from_user, to_user)
    return if from_user.blank? || to_user.blank?

    exchange_ratings.find_by(rater_id: from_user.id, ratee_id: to_user.id)
  end

  private

  def participants_match_conversation
    return if conversation.blank? || buyer.blank? || seller.blank?

    participant_ids = conversation.participants.pluck(:id)
    return if participant_ids.include?(buyer_id) && participant_ids.include?(seller_id)

    errors.add(:base, "Buyer and seller must both participate in this conversation")
  end
end
