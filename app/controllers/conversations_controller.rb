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
  end

  private

  def set_conversation
    @conversation = Conversation.for_user(current_user).find(params[:id])
  end
end
