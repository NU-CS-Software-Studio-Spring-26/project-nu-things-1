# frozen_string_literal: true

class ConversationsController < ApplicationController
  before_action :require_login
  before_action :set_conversation, only: :show

  def index
    @conversations = Conversation.for_user(current_user).recent_first
      .includes(:listable, :conversation_messages, :participants)
  end

  def show
    @messages = @conversation.conversation_messages.includes(:sender).order(:created_at)
    @conversation.mark_read_for!(current_user)
    @new_message = ConversationMessage.new
    load_marketplace_transaction
  end

  private

  def load_marketplace_transaction
    return unless @conversation.listable.is_a?(MarketplaceListing)

    @marketplace_transaction = MarketplaceTransaction.find_or_create_for!(@conversation)
  rescue MarketplaceTransaction::InvalidConversation
    @marketplace_transaction = nil
  end

  def set_conversation
    @conversation = Conversation.for_user(current_user).find(params[:id])
  end
end
