# frozen_string_literal: true

class ListingConversationsController < ApplicationController
  before_action :require_login

  rate_limit to: 24, within: 1.hour, scope: :listing_conversation_starts,
             by: -> { "listing_conversations/user/#{current_user.id}" }, with: :notify_rate_limit,
             only: :create

  def create
    listable = find_listable
    body = params[:message].to_s.strip

    if body.blank?
      redirect_to listable, alert: "Please enter a message."
      return
    end

    if Moderate::Text.bad_words?(body)
      redirect_to listable, alert: profanity_blocked_alert
      return
    end

    conversation = ConversationStarter.start!(listable: listable, sender: current_user, body: body)
    redirect_to conversation_path(conversation), notice: "Your message has been sent."
  rescue ConversationStarter::BlockedUser
    redirect_to listable, alert: "You cannot message this user."
  rescue ConversationStarter::SelfMessage
    redirect_to listable, alert: "You cannot message your own listing."
  rescue ConversationStarter::OwnerMissing
    redirect_to listable,
                alert: "This poster has not linked a Northwestern account yet, so on-site messaging is unavailable."
  rescue ActiveRecord::RecordInvalid
    redirect_to listable, alert: profanity_blocked_alert
  end

  private

  def find_listable
    listable = if params[:lost_item_id]
      LostItem.find(params[:lost_item_id])
    elsif params[:found_item_id]
      FoundItem.find(params[:found_item_id])
    elsif params[:rental_item_id]
      RentalItem.find(params[:rental_item_id])
    elsif params[:marketplace_listing_id]
      MarketplaceListing.find(params[:marketplace_listing_id])
    else
      raise ActiveRecord::RecordNotFound
    end

    ensure_listing_visible!(listable)
    listable
  end
end
