# frozen_string_literal: true

class ConversationsController < ApplicationController
  before_action :require_login
  before_action :set_conversation, only: :show

  def index
    @conversations = Conversation.for_user(current_user).recent_first
      .includes(:listable, :conversation_messages, :participants)
      .select { |conversation| conversation_visible?(conversation) }
  end

  def show
    if conversation_blocked_for_viewer?
      redirect_to conversations_path, alert: "You cannot access this conversation."
      return
    end

    @messages = @conversation.conversation_messages.includes(:sender).order(:created_at)
    @conversation.mark_read_for!(current_user)
    @new_message = ConversationMessage.new
  end

  private

  def set_conversation
    @conversation = Conversation.for_user(current_user).find(params[:id])
  end

  def conversation_visible?(conversation)
    other = conversation.other_participant(current_user)
    other.blank? || !other.blocking?(current_user)
  end

  def conversation_blocked_for_viewer?
    other = @conversation.other_participant(current_user)
    other.present? && other.blocking?(current_user)
  end
end
