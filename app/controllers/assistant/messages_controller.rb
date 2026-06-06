# frozen_string_literal: true

module Assistant
  class MessagesController < ApplicationController
    include AssistantSession

    before_action :require_login

    rate_limit to: 30, within: 1.hour, scope: :assistant_messages,
               by: -> { "assistant/user/#{current_user.id}" }, with: :notify_rate_limit,
               only: :create

    def create
      unless Rails.application.config.x.gemini_api_key.present?
        redirect_to assistant_path, alert: "AI assistant is not configured. Set GEMINI_API_KEY."
        return
      end

      body = params[:message].to_s.strip
      if body.blank?
        redirect_to assistant_path, alert: "Please enter a message."
        return
      end

      if defined?(Moderate::Text) && Moderate::Text.bad_words?(body)
        redirect_to assistant_path, alert: profanity_blocked_alert
        return
      end

      append_assistant_user_message!(body)

      history = assistant_history_for_prompt[0...-1]
      result = Assistant::Chat.process!(message: body, history: history)
      append_assistant_bot_message!(reply: result.reply, listings: result.listings)

      redirect_to assistant_path
    rescue Assistant::Chat::Error, GeminiClient::Error => e
      redirect_to assistant_path, alert: e.message
    end
  end
end
