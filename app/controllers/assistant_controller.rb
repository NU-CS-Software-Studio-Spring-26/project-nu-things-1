# frozen_string_literal: true

class AssistantController < ApplicationController
  include AssistantSession

  before_action :require_login

  def show
    @messages = assistant_chat_messages
    @gemini_configured = Rails.application.config.x.gemini_api_key.present?
  end

  def clear
    clear_assistant_chat!
    redirect_to assistant_path, notice: "Chat cleared."
  end
end
