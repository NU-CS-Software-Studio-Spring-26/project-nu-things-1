# frozen_string_literal: true

class ConversationMessagesController < ApplicationController
  before_action :require_login
  before_action :set_conversation

  rate_limit to: 60, within: 1.hour, scope: :conversation_message_posts,
             by: -> { "conversation_messages/user/#{current_user.id}" }, with: :notify_rate_limit,
             only: :create

  def create
    @message = @conversation.conversation_messages.build(
      sender: current_user,
      body: message_params[:body]
    )

    if @message.save
      @conversation.update!(last_message_at: @message.created_at)
      @conversation.mark_read_for!(current_user, at: @message.created_at)
      redirect_to conversation_path(@conversation), notice: "Message sent."
    else
      @messages = @conversation.conversation_messages.includes(:sender).order(:created_at)
      @new_message = @message
      render "conversations/show", status: :unprocessable_entity
    end
  end

  private

  def set_conversation
    @conversation = Conversation.for_user(current_user).find(params[:conversation_id])
  end

  def message_params
    params.require(:conversation_message).permit(:body)
  end
end
