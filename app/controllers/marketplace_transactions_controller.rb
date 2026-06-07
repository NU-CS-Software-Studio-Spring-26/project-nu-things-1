# frozen_string_literal: true

class MarketplaceTransactionsController < ApplicationController
  before_action :require_login
  before_action :set_conversation
  before_action :set_transaction

  rate_limit to: 10, within: 1.hour, scope: :marketplace_exchange_ratings,
             by: -> { "marketplace_exchange_ratings/user/#{current_user.id}" }, with: :notify_rate_limit,
             only: :rate_exchange

  def mark_buyer_complete
    unless @transaction.buyer_id == current_user.id
      redirect_to conversation_path(@conversation), alert: "Only the buyer can confirm they received the item."
      return
    end

    if @transaction.buyer_marked_complete?
      redirect_to conversation_path(@conversation), notice: "You already confirmed you received the item."
      return
    end

    @transaction.update!(buyer_marked_complete_at: Time.current)
    redirect_to conversation_path(@conversation), notice: buyer_marked_notice
  end

  def mark_seller_complete
    unless @transaction.seller_id == current_user.id
      redirect_to conversation_path(@conversation), alert: "Only the seller can confirm they received payment."
      return
    end

    if @transaction.seller_marked_complete?
      redirect_to conversation_path(@conversation), notice: "You already confirmed you received payment."
      return
    end

    @transaction.update!(seller_marked_complete_at: Time.current)
    redirect_to conversation_path(@conversation), notice: seller_marked_notice
  end

  def rate_exchange
    ratee = @transaction.exchange_ratee_for(current_user)
    unless ratee
      redirect_to conversation_path(@conversation), alert: "You can't rate this exchange."
      return
    end

    unless @transaction.complete?
      redirect_to conversation_path(@conversation), alert: "You can only rate after both sides confirm the purchase is complete."
      return
    end

    if @transaction.exchange_rating_from_to(current_user, ratee).present?
      redirect_to conversation_path(@conversation), notice: "You've already rated this user for this purchase."
      return
    end

    rating = @transaction.exchange_ratings.build(exchange_rating_params)
    rating.rater = current_user
    rating.ratee = ratee

    if rating.save
      redirect_to conversation_path(@conversation), notice: "Thanks for rating your exchange partner!"
    else
      redirect_to conversation_path(@conversation), alert: rating.errors.full_messages.join(", ")
    end
  end

  private

  def set_conversation
    @conversation = Conversation.for_user(current_user).find(params[:conversation_id])
    return if @conversation.listable.is_a?(MarketplaceListing)

    redirect_to conversation_path(@conversation), alert: "This action is only available for marketplace conversations." and return
  end

  def set_transaction
    @transaction = MarketplaceTransaction.find_or_create_for!(@conversation)
  rescue MarketplaceTransaction::InvalidConversation
    redirect_to conversation_path(@conversation), alert: "This marketplace conversation cannot track a purchase yet." and return
  end

  def exchange_rating_params
    params.expect(exchange_rating: [ :rating, :body ])
  end

  def buyer_marked_notice
    if @transaction.complete?
      "You confirmed you received the item. The purchase is now closed on both sides."
    else
      "You confirmed you received the item. Waiting for the seller to confirm payment."
    end
  end

  def seller_marked_notice
    if @transaction.complete?
      "You confirmed you received payment. The purchase is now closed on both sides."
    else
      "You confirmed you received payment. Waiting for the buyer to confirm they received the item."
    end
  end
end
